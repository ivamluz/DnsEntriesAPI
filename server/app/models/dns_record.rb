require 'resolv'

class DnsRecord < ApplicationRecord
  has_and_belongs_to_many :hostnames
  validates :ip, presence: true, format: { with: Resolv::IPv4::Regex }

  def self.create_or_replace_with_hostnames!(ip, hostname_names)
    hostnames = hostname_names.map do |hostname|
      Hostname.where(hostname: hostname).first_or_initialize(hostname: hostname)
    end

    record = DnsRecord.where(ip: ip).first_or_initialize(ip: ip)
    record.hostnames = hostnames
    record.save!

    return record
  end
end
