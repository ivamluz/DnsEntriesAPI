require 'test_helper'

class DnsRecordsControllerTest < ActionDispatch::IntegrationTest
  test "returns hard-coded value" do
    get dns_records_url
    
    assert_response :success
    assert_equal "application/json", @response.media_type
    
    @expected_response = {
      :total_records => 1,
      :records => [
        {
          :id => 1,
          :ip_address => "1.1.1.1"
        },
       ],
      :related_hostnames => [
        {
          :hostname => "lorem.com",
          :count => 5
        },
      ],
    }

    assert_equal @expected_response.to_json, @response.body
  end

  test "post request" do
    post dns_records_url, params: {
      dns_records: {
        ip: "1.1.1.1",
        hostnames_attributes: [
          {
            hostname: "lorem.com"
          }
        ]
      }
    }

    assert_response :success
    assert_equal "application/json", @response.media_type

    @expected_response = {
      :id => 1,
    }

    assert_equal @expected_response.to_json, @response.body
  end
end
