class DnsRecordsController < ApplicationController
  def show
    params.require(:page)

    permitted = params.permit(
      :page,
      included: [], 
      excluded: []
    )

    page = permitted[:page]
    included = permitted[:included]
    excluded = permitted[:excluded]

    results = DnsRecord.filter_by_included_and_excluded(included, excluded, page)

    render json: results.to_json
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
