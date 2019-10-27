ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...

  def assert_ip_has_saved_hostnames(ip, hostnames)
    record = DnsRecord.find_by! ip: ip

    saved_hostnames = record.hostnames.map do |hostname|
      hostname.hostname
    end

    assert_equal ip, record.ip
    assert_equal hostnames, saved_hostnames
  end
end
