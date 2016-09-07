require 'spec_helper'
require_relative './shared_context'

describe Fog::Share::OpenStack do
  spec_data_folder = 'spec/fixtures/openstack/share'

  before :all do
    openstack_vcr = OpenStackVCR.new(
      :vcr_directory  => spec_data_folder,
      :project_scoped => true,
      :service_class  => Fog::Share::OpenStack
    )
    @service = openstack_vcr.service

    net_openstack_vcr = OpenStackVCR.new(
      :vcr_directory  => spec_data_folder,
      :project_scoped => true,
      :service_class  => Fog::Network::OpenStack
    )
    @network_service = net_openstack_vcr.service
  end

  it "CRUD & list shares" do
    VCR.use_cassette('share_crud') do
      share_protocol            = 'NFS'
      share_size                = 1
      share_name                = 'fog_share'
      share_net_name            = 'fog_share_net'
      share_description         = 'used by fog'
      share_updated_description = 'still used by fog'

      begin
        # assuming a network exists
        net = @network_service.networks.first

        # create a share network
        share_network = @service.networks.create(
          :neutron_net_id    => net.id,
          :neutron_subnet_id => net.subnets.first.id,
          :name              => share_net_name
        )

        # create share
        example_share = @service.shares.create(
          :share_proto      => share_protocol,
          :size             => share_size,
          :name             => share_name,
          :description      => share_description,
          :share_network_id => share_network.id
        )
        example_share.status.must_equal 'creating'
        example_id = example_share.id

        # update display description
        example_share.update(:display_description => share_updated_description)
        example_share.reload.description.must_equal share_updated_description

        # get by ID
        example_share_by_id = @service.shares.find_by_id example_id
        example_share_by_id.wont_equal nil
        example_share_by_id.name.must_equal share_name

        # get by filtering list by name
        shares = @service.shares.all(:name => share_name)
        shares.length.must_equal 1
        shares.first.id.must_equal example_id
      ensure
        # delete the share(s)
        @service.shares.all(:name => share_name).each(&:destroy)
        # check delete action
        @service.shares.all(:name => share_name).length.must_equal 0

        # delete the share network
        @service.networks.all(:name => share_net_name).each(&:destroy)
      end
    end
  end

  it "CRUD & list share_networks" do
    VCR.use_cassette('share_net_crud') do
      share_net_name                = 'fog_share_network'
      share_net_description         = 'used by fog'
      share_net_updated_description = 'still used by fog'
      begin
        # assuming a network exists
        net = @network_service.networks.first

        # create a share network
        share_network = @service.networks.create(
          :neutron_net_id    => net.id,
          :neutron_subnet_id => net.subnets.first.id,
          :name              => share_net_name,
          :description       => share_net_description
        )
        share_network.description.must_equal share_net_description
        share_net_id = share_network.id

        # update description
        share_network.update(:description => share_net_updated_description)
        share_network.reload.description.must_equal share_net_updated_description

        # get by ID
        share_net_by_id = @service.networks.find_by_id share_net_id
        share_net_by_id.wont_equal nil
        share_net_by_id.name.must_equal share_net_name

        # get by filtering list by name
        share_nets = @service.networks.all(:name => share_net_name)
        share_nets.length.must_equal 1
        share_nets.first.id.must_equal share_net_id
      ensure
        # delete the share network
        @service.networks.all(:name => share_net_name).each(&:destroy)
        # check delete action
        @service.networks.all(:name => share_net_name).length.must_equal 0
      end
    end
  end
end
