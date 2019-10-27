class CreateDnsRecordsAndHostnames < ActiveRecord::Migration[5.2]
  def change
    create_table :dns_records do |t|
      t.string :ip
      t.timestamps
    end
    change_column_null :dns_records, :ip, false
    add_index :dns_records, :ip

    create_table :hostnames do |t|
      t.string :hostname
      t.timestamps
    end
    change_column_null :hostnames, :hostname, false
    add_index :hostnames, :hostname

    create_table :dns_records_hostnames, id: false do |t|
      t.belongs_to :dns_record, foreign_key: true
      t.belongs_to :hostname, foreign_key: true
    end
    change_column_null :dns_records_hostnames, :dns_record_id, false
    change_column_null :dns_records_hostnames, :hostname_id, false
  end
end
