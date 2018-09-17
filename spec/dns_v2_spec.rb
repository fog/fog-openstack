require 'spec_helper'
require_relative './shared_context'

describe Fog::OpenStack::DNS::V2 do
  spec_data_folder = 'spec/fixtures/openstack/dns_v2'

  before :all do
    openstack_vcr = OpenStackVCR.new(
      :vcr_directory  => spec_data_folder,
      :project_scoped => true,
      :service_class  => Fog::OpenStack::DNS # Fog to choose latest available version
    )
    @service = openstack_vcr.service
  end

  it "CRUD & list zones" do
    VCR.use_cassette('zone_crud') do
      zone = 'example.org'
      zone_name = "#{zone}."
      zone_description = 'fog testing'

      begin
        # create zone
        example_zone = @service.zones.create(:name => zone_name, :email => "hostmaster@#{zone}")
        example_zone.status.must_equal 'PENDING'
        example_zone.action.must_equal 'CREATE'
        example_id = example_zone.id

        # add a description
        example_zone.update(:description => zone_description)
        example_zone.reload.description.must_equal zone_description

        # get by ID
        example_zone_by_id = @service.zones.find_by_id example_id
        example_zone_by_id.wont_equal nil
        example_zone_by_id.description.must_equal zone_description

        # get by filtering list by name
        zones = @service.zones.all(:name => zone_name)
        zones.length.must_equal 1
        zones.first.id.must_equal example_id
      ensure
        # delete the zone(s)
        @service.zones.all(:name => zone_name).each(&:destroy)

        # check delete action
        @service.zones.all(:name => zone_name).each do |z|
          z.action.must_equal 'DELETE'
        end
      end
    end
  end

  it "CRUD & list recordsets" do
    VCR.use_cassette('recordset_crud') do
      zone = 'example2.org'
      zone_name = "#{zone}."
      recordset_name = "host.#{zone_name}"
      records = ['10.0.0.1']
      records_updated = ['10.0.0.2']

      begin
        # create zone
        example_zone = @service.zones.create(:name => zone_name, :email => "hostmaster@#{zone}")
        example_id = example_zone.id

        # create recordset
        host_record = @service.recordsets.create(
          :zone_id => example_id,
          :name    => recordset_name,
          :type    => 'A',
          :records => records
        )
        host_id = host_record.id

        # change record
        host_record.update(:records => records_updated)
        host_record.reload.records.must_equal records_updated

        # get by ID
        host_record_by_id = @service.recordsets.find_by_id(example_id, host_id)
        host_record_by_id.wont_equal nil
        host_record_by_id.records.must_equal records_updated

        # get by filtering list by name
        recordsets = @service.recordsets.all(:zone_id => example_id, :name => recordset_name)
        recordsets.length.must_equal 1
        recordsets.first.id.must_equal host_id
      ensure
        # delete the recordset(s)
        @service.recordsets.all(:zone_id => example_id, :name => recordset_name).each(&:destroy)
        # delete the zone(s)
        @service.zones.all(:name => zone_name).each(&:destroy)
      end
    end
  end
end
