class DnsRecordsController < ApplicationController
  def show
    @result = {
      total_records: 2,
      records: [
        {
          id: 1,
          ip_address: '1.1.1.1'
        },
        {
          id: 3,
          ip_address: '3.3.3.3'
        }
      ],
      related_hostnames: [
        {
          hostname: 'lorem.com',
          count: 1
        },
        {
          hostname: 'amet.com',
          count: 2
        }
      ]
    }

    render json: @result.to_json
  end

  def create
    permitted = params.require(:dns_records).permit(
      :ip, 
      hostnames_attributes: [:hostname]
    )

    ip = permitted[:ip]

    hostnames = permitted[:hostnames_attributes].map do |params|
      params['hostname']
    end

    record = DnsRecord.create_or_replace_with_hostnames!(ip, hostnames)

    render json: {
      id: record.id
    }
  end

  def update
    raise NotImplementedError
  end

  def destroy
    raise NotImplementedError
  end
end
