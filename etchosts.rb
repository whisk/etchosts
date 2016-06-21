#!/usr/bin/env ruby

require 'optparse'
require 'ipaddr'

class IPAddr
  @@cidr_loopback = IPAddr.new '127.0.0.0/8'
  @@cidr_local    = IPAddr.new '192.168.0.0/16'

  def <=>(anoter)
    to_i <=> anoter.to_i
  end

  def cat
    if @@cidr_loopback === self
      return :loopback
    elsif @@cidr_local === self
      return :local
    elsif ipv6?
      return :ipv6
    else
      return :real
    end
  end
end

class EtcHosts
  private

  @@verbosity_levels = { error: 0, warn: 1, info: 2, verbose: 3, debug: 4 }
  attr_accessor :input_files, :names, :ips, :files

  public

  attr_accessor :opts

  def initialize
    @opts = {}
    @opts[:verbosity] = :info
    @input_files = {}
    @names = {}
    @ips = {}
    @files = {}
  end

  def run!
    analyze
    dump_analyze_names if @opts[:names]
    dump_analyze_addr if @opts[:addr]
    dump_etchosts if @opts[:generate]
  end

  def add_file(fname)
    input_files[fname] = File.open(fname, 'r')
  rescue StandardError => e
    error(e.to_s)
    exit(1)
  end

  def analyze
    input_files.each do |fname, fh|
      verbose("Scanning file #{fname}...")
      l = t = 0
      fh.readlines.each do |line|
        l += 1
        # strip comments
        # and split to tokens
        tokens = line.split(/#/, 2).first.split
        next if tokens.empty?

        if validate(tokens)
          add_host(fname, tokens)
          t += 1
        else
          warn("Invalid entry: #{tokens}")
        end
      end
      verbose("Read #{l} lines, #{t} tokens")
    end
  end

  private

  def add_host(fname, tokens)
    ip = IPAddr.new(tokens.shift)
    files[ip] = (files[ip] ? files[ip] + [fname] : [fname]).uniq

    tokens.each do |name|
      names[name] = (names[name] ? names[name] + [ip] : [ip]).uniq
      ips[ip] = (ips[ip] ? ips[ip] + [name] : [name]).uniq
      files[name] = (files[name] ? files[name] + [fname] : [fname]).uniq
    end
  end

  def dump_analyzed_data(data, fmt = '%-15s')
    data.keys.sort.each do |key|
      msg = format(fmt, key)
      if files[key].size != input_files.size
        msg += format(' found on %d host(s): %s.', files[key].size, files[key].join(', '))
      else
        msg += ' found on all hosts.'
      end

      if data[key].size == 1
        msg += format(' Entry: %s', data[key].first)
      else
        msg += format(' Multiple entries: %s', data[key].join(', '))
      end
      output(msg)
    end
  end

  def dump_analyze_addr
    output('Addresses:')
    dump_analyzed_data(ips)
  end

  def dump_analyze_names
    output('Names:')
    dump_analyzed_data(names, '%-24s')
  end

  def dump_etchosts
    output('# Sample /etc/hosts compiled from %d files', input_files.size)
    res = { local: {}, real: {}, loopback: {}, ipv6: {} }
    ips.keys.each do |ip|
      res[ip.cat][ip] = ips[ip]
    end

    output('# loopback interfaces skipped')
    output('# ipv6 addresses skipped')
    [:real, :local].each do |cat|
      output("# #{cat}")
      res[cat].keys.sort.each do |ip|
        msg = format('%-16s', ip) + ips[ip].sort.join(' ')
        dups = ips[ip].find_all { |e| names[e].size > 1 }
        unless dups.empty?
          msg += ' # WARNING: multiple addresses' 
          msg += format(' for %s', dups.join(', ')) if ips[ip].size > 1
        end
        output(msg)
      end
    end
  end

  def message(level, *msg)
    print(format(*msg) + "\n") if @@verbosity_levels[opts[:verbosity]] >= @@verbosity_levels[level]
  end

  def output(*msg)
    printf(*msg)
    print("\n")
  end

  @@verbosity_levels.keys.each do |l|
    define_method(l) do |*msg|
      message(l, *msg)
    end
  end

  def validate(tokens)
    tokens.size > 1
  end
end

etchosts = EtcHosts.new
OptionParser.new do |opts|
  opts.banner = 'Usage: etchosts.rb [options] FILE [FILE ...]'
  opts.on('-n', 'Analyze names') do
    etchosts.opts[:names] = true
  end
  opts.on('-a', 'Analyze addresses') do
    etchosts.opts[:addr] = true
  end
  opts.on('-g', 'Generate sample /etc/hosts') do
    etchosts.opts[:generate] = true
  end
  opts.on('-v', '--verbose', 'Run verbosely') do
    etchosts.opts[:verbosity] = :verbose
  end
  opts.on('-d', '--debug', 'Add debug information') do
    etchosts.opts[:verbosity] = :debug
  end
end.parse!

ARGV.each do |fname|
  etchosts.add_file(fname)
end

etchosts.run!
