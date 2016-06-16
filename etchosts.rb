#!/usr/bin/env ruby

require 'optparse'
require 'ipaddr'

class IPAddr
  @@cidr_loopback = IPAddr.new '127.0.0.0/8'
  @@cidr_local    = IPAddr.new '192.168.0.0/16'

  def <=>(anoter)
    self.to_i <=> anoter.to_i
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

  attr_accessor :verbosity

  def initialize
    @verbosity = :info

    @input_files = {}

    @names = {}
    @ips = {}
    @files = {}
  end

  def run!
    analyze
    dump_analyze
    dump_etchosts
  end

  def add_file(fname)
    input_files[fname] = File.open(fname, 'r')
  rescue StandardError => e
    error(e.to_s)
    exit(1)
  end

  def analyze
    input_files.each do |fname, fh|
      debug("Scanning file #{fname}...")
      fh.readlines.each do |line|
        # strip comments
        # and split to tokens
        tokens = line.split(/#/, 2).first.split
        next if tokens.empty?

        if validate(tokens)
          add_host(fname, tokens)
        else
          warn("Invalid entry: #{tokens}")
        end
      end
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

  def dump_analyze
    output("Addresses:")
    ips.keys.sort.each do |ip|
      msg = format('%-15s', ip)
      if files[ip].size != input_files.size
        msg += format(' found on %d host(s): %s.', files[ip].size, files[ip].join(', '))
      else
        msg += ' found on all hosts'
      end
      msg += format(' Names: %s', ips[ip].join(', '))
      output(msg)
    end

    output("Names:")
    names.keys.sort.each do |name|
      msg = format("%-20s", name)
      if files[name].size != input_files.size
        msg += format(' found on %d host(s): %s.', files[name].size, files[name].join(', '))
      else
        msg += ' found on all hosts.'
      end
      msg += format(' Addresses: %s', names[name].join(', '))
      output(msg)
    end
  end

  def dump_etchosts
    output('Sample /etc/hosts')
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
        output(msg)
      end
    end
  end

  def message(level, *msg)
    print(format(*msg) + "\n") if @@verbosity_levels[verbosity] >= @@verbosity_levels[level]
  end

  def output(*msg)
    printf(*msg)
    print "\n"
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
  opts.on('-v', '--verbose', 'Run verbosely') do
    etchosts.verbosity = :verbose
  end
  opts.on('-d', '--debug', 'Add debug information') do
    etchosts.verbosity = :debug
  end  
end.parse!

ARGV.each do |fname|
  etchosts.add_file(fname)
end

etchosts.run!
