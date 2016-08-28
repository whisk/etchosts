require 'test/unit'
require 'shoulda-context'
require_relative '../etchosts'

class IPAddrTest < Test::Unit::TestCase
  context 'cat'  do
    should 'be loopback' do
      assert_equal :loopback, IPAddr.new('127.0.0.1').cat
      assert_equal :loopback, IPAddr.new('127.0.0.255').cat
      assert_equal :loopback, IPAddr.new('127.0.1.1').cat
      assert_equal :loopback, IPAddr.new('127.1.1.1').cat
      assert_not_equal :loopback, IPAddr.new('128.0.0.1').cat
    end

    should 'be ipv6' do
      assert_equal :ipv6, IPAddr.new('::ff').cat
      assert_equal :ipv6, IPAddr.new('FE80:0000:0000:0000:0202:B3FF:FE1E:8329').cat
    end

    should 'be local' do
      assert_equal :local, IPAddr.new('192.168.0.1').cat
      assert_equal :local, IPAddr.new('192.168.1.1').cat
    end

    should 'be allowed' do
      assert IPAddr.new('192.168.0.1').allowed?
      assert IPAddr.new('81.177.123.108').allowed?
      assert IPAddr.new('8.8.8.8').allowed?
    end

    should 'be not allowed' do
      assert_false IPAddr.new('127.0.0.1').allowed?
      assert_false IPAddr.new('127.0.1.1').allowed?
    end

    should 'be comparable' do
      assert_equal 1,  IPAddr.new('192.168.0.2') <=> IPAddr.new('192.168.0.1')
      assert_equal -1, IPAddr.new('8.8.8.8') <=> IPAddr.new('81.177.123.108')
      assert_equal 0,  IPAddr.new('192.168.0.1') <=> IPAddr.new('192.168.0.1')
    end
  end
end