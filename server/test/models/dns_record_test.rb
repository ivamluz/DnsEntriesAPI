require 'test_helper'

class DnsRecordTest < ActiveSupport::TestCase
  test 'Should accept valid IPs' do
    valid_ips = [
      '0.0.0.0',
      '255.255.255.255',
      '192.169.0.1',
      '8.8.8.8'
    ]

    valid_ips.each do |ip|
      record = DnsRecord.new(ip: ip)    
      assert record.valid?
    end
  end

  test 'Should not accept null IPs' do
    record = DnsRecord.new()
    assert record.invalid?
  end

  test 'Should not accept empty IPs' do
    record = DnsRecord.new(ip: '   ')
    assert record.invalid?
  end

  test 'Should not accept invalid IP formats' do
    invalid_ips = {
      "1" => "Invalid mask",
      "1." => "Invalid mask",
      "1.1" => "Invalid mask",
      "1.1." => "Invalid mask",
      "1.1.1" => "Invalid mask",
      "1.1.1." => "Invalid mask",
      "..." => "Invalid mask",
      "1...1" => "Invalid mask",
      "258.258.258.258" => "Invalid value",
    }

    invalid_ips.each do |ip, reason|
      record = DnsRecord.new(ip: ip)
      assert record.invalid?, "#{reason}: #{ip}"
    end
  end
end
