class DnsRecordsController < ApplicationController
  def show
    @result = {
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

    render json: @result.to_json
  end

  def create
    logger.debug "Creating new DnsRecord with params: #{params[:foo]}"

    @result = {
      :id => 1,
    }

    render json: @result.to_json
  end

  def update
    raise NotImplementedError
  end

  def destroy
    raise NotImplementedError
  end
end
