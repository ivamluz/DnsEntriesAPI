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

  test 'Should create record without hostnames' do
    assert_dns_record_creation_with_hostnames('10.10.10.10', [])
  end

  test 'Should create record with single hostname' do
    hostnames = ['ipsum.com']
    assert_dns_record_creation_with_hostnames('10.10.10.10', hostnames)
  end

  test 'Should create record with multiple hostnames' do
    hostnames = ['ipsum.com', 'amet.com']
    assert_dns_record_creation_with_hostnames('10.10.10.10', hostnames)
  end

  test 'Should replace associated hostnames' do
    hostnames = ['ipsum.com', 'amet.com']
    assert_dns_record_creation_with_hostnames('10.10.10.10', hostnames)

    assert_dns_record_creation_with_hostnames('10.10.10.10', ['sit.com'])
  end

  def assert_dns_record_creation_with_hostnames(ip, hostnames)
    DnsRecord.create_or_replace_with_hostnames!(ip, hostnames)
    record = DnsRecord.find_by! ip: ip

    saved_hostnames = record.hostnames.map do |hostname|
      hostname.hostname
    end

    assert_equal ip, record.ip
    assert_equal hostnames, saved_hostnames
  end
end
