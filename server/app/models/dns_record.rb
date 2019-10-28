require 'resolv'

class DnsRecord < ApplicationRecord
  has_and_belongs_to_many :hostnames
  validates :ip, presence: true, format: { with: Resolv::IPv4::Regex }

  def self.create_or_replace_with_hostnames!(ip, hostname_names)
    hostnames = hostname_names.uniq{ |hostname| 
      hostname
    }.map { |hostname|
      Hostname.where(hostname: hostname).first_or_initialize(hostname: hostname)
    }

    record = DnsRecord.where(ip: ip).first_or_initialize(ip: ip)
    record.hostnames = hostnames
    record.save!

    return record
  end

  def self.filter_by_included_and_excluded(included, excluded, page)
    # TODO: use page to paginate results
    # TODO: check query performance with a bigger dataset

    query = %q(
          SELECT r.id,
                 r.ip, 
                 h.hostname
            FROM dns_records r
                 INNER JOIN dns_records_hostnames rh
                         ON r.id = rh.dns_record_id
                 INNER JOIN hostnames h
                         ON rh.hostname_id = h.id
                 INNER JOIN (
                        SELECT rh.dns_record_id
                          FROM dns_records_hostnames rh
                    INNER JOIN hostnames h ON rh.hostname_id = h.id
                          WHERE h.hostname IN ('ipsum.com', 'dolor.com')
                      GROUP BY rh.dns_record_id
                        HAVING COUNT(DISTINCT h.hostname) = 2
                  EXCEPT
                        SELECT rh.dns_record_id
                          FROM dns_records_hostnames rh
                          JOIN hostnames h on rh.hostname_id = h.id
                          WHERE h.hostname IN ('sit.com')
                 ) AS filtered
                         ON r.id = filtered.dns_record_id
           WHERE h.hostname not in ('ipsum.com', 'dolor.com')
    )

    #TODO: check if there is a better place to do this transformation

    dns_records = {}
    hostnames = {}

    records = DnsRecord.find_by_sql(query)
    records.each do |record|
      dns_records[record.id] = {
        id: record.id,
        ip_address: record.ip
      }

      hostnames[record.hostname] = hostnames[record.hostname].to_i.succ      
    end

    result = {
      total_records: dns_records.length,
      records: dns_records.values,
      related_hostnames: hostnames.map { |hostname, count|
        {
          hostname: hostname,
          count: count
        }
      }
    }

    return result
  end
end
