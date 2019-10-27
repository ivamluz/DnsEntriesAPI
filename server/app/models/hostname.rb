require 'uri'

class Hostname < ApplicationRecord
  has_and_belongs_to_many :dns_records

  validates :hostname, presence: true, format: { with: Regexp.new("\\A#{URI::PATTERN::HOSTNAME}\\z") }
end
