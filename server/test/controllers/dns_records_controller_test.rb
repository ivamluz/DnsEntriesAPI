require 'test_helper'

class DnsRecordsControllerTest < ActionDispatch::IntegrationTest
  test 'Should filter correctly by hostname' do
    get dns_records_url, params: {
      included: ['ipsum.com', 'dolor.com'], 
      excluded: ['sit.com'],
      page: 1
    }

    records_by_ip = response.parsed_body['records'].map { |record| 
      [ record['ip_address'], record['id'] ] 
    }.to_h
    
    hostnames_by_hostname = response.parsed_body["related_hostnames"].map { |hostname| 
      puts hostname
      [ hostname['hostname'], hostname['count'] ] 
    }.to_h

    assert_response :success
    assert_equal 'application/json', @response.media_type
    
    assert_equal 2, response.parsed_body['total_records']
    assert_equal 2, response.parsed_body['records'].length
    assert_equal 2, response.parsed_body['related_hostnames'].length

    assert_not_nil records_by_ip['1.1.1.1']
    assert_not_nil records_by_ip['3.3.3.3']

    assert_equal 1, hostnames_by_hostname['lorem.com']
    assert_equal 2, hostnames_by_hostname['amet.com']
  end

  test 'Should return DNS Record ID when a new record is created' do
    payload = build_post_payload('100.100.100.100', [])
    post dns_records_url, params: payload

    assert_response :success
    assert_equal 'application/json', @response.media_type

    id = response.parsed_body["id"]
    
    assert_not_nil id
    assert id > 0
  end

  test 'Should return DNS Record ID when an existing record is updated' do
    payload = build_post_payload('100.100.100.100', [])
    
    post dns_records_url, params: payload
    first_id = response.parsed_body["id"]

    post dns_records_url, params: payload
    second_id = response.parsed_body["id"]

    assert_equal first_id, second_id
  end  

  test 'Should create DNS record without hostnames' do
    ip = '100.100.100.100'
    hostnames = []

    payload = build_post_payload(ip, hostnames)
    post dns_records_url, params: payload

    assert_ip_has_saved_hostnames(ip, hostnames)
  end

  test 'Should create DNS record with single hostname' do
    ip = '100.100.100.100'
    hostnames = ['sit.com']

    payload = build_post_payload(ip, hostnames)
    post dns_records_url, params: payload

    assert_ip_has_saved_hostnames(ip, hostnames)
  end

  test 'Should create DNS record with multiple hostnames' do
    ip = '100.100.100.100'
    hostnames = ['sit.com', 'amet.com']

    payload = build_post_payload(ip, hostnames)
    post dns_records_url, params: payload

    assert_ip_has_saved_hostnames(ip, hostnames)
  end

  test 'Should create DNS record with multiple hostnames filtering duplicates' do
    ip = '100.100.100.100'
    hostnames = ['sit.com', 'amet.com', 'sit.com', 'amet.com']

    payload = build_post_payload(ip, hostnames)
    post dns_records_url, params: payload

    assert_ip_has_saved_hostnames(ip, ['sit.com', 'amet.com'])
  end

  test 'Should update existing DNS record with multiple hostnames without duplicating' do
    ip = '100.100.100.100'
    hostnames = ['sit.com', 'amet.com', 'lorem.com']
    payload = build_post_payload(ip, hostnames)
    post dns_records_url, params: payload
    assert_ip_has_saved_hostnames(ip, hostnames)

    ip = '100.100.100.100'
    hostnames = ['sit.com', 'lorem.com', 'ipsum.com', 'dolor.com']
    payload = build_post_payload(ip, hostnames)
    post dns_records_url, params: payload
    assert_ip_has_saved_hostnames(ip, hostnames)
  end

  def build_post_payload(ip, hostnames)
    return {
      dns_records: {
        ip: ip,
        hostnames_attributes: hostnames.map{ |h| { hostname: h } }
      }
    }
  end
end
