require 'test_helper'

class HostnameTest < ActiveSupport::TestCase
  test 'Should accept valid fully qualified domains' do
    hostnames = [
      'www.google.com',
      'test.foob.ar'
    ]

    hostnames.each do |h|
      hostname = Hostname.new(hostname: h)
      assert hostname.valid?
    end
  end

  test 'Should accept naked domains' do
    hostname = Hostname.new(hostname: 'google.com')
    assert hostname.valid?
  end

  test 'Should not accept null hostnames' do
    hostname = Hostname.new()
    assert hostname.invalid?
  end

  test 'Should not accept empty hostnames' do
    hostname = Hostname.new(hostname: '   ')
    assert hostname.invalid?
  end

  test 'Should not accept invalid hostnames' do
    hostnames = [
      '!jkfd.com',
      '@mfd.com',
      'jkfd@jkfdkd.com',
      'http://www.foo.com',
      'www.foo.com/bar'
    ]

    hostnames.each do |h|
      hostname = Hostname.new(hostname: h)

      assert hostname.invalid?, "#{h} should be invalid."
    end
  end
end
