require 'spec_helper'
require_relative './shared_context'

describe Fog::OpenStack::SharedFileSystem do
  spec_data_folder = 'spec/fixtures/openstack/shared_file_system'

  before :all do
    openstack_vcr = OpenStackVCR.new(
      :vcr_directory  => spec_data_folder,
      :project_scoped => true,
      :service_class  => Fog::OpenStack::SharedFileSystem
    )
    @service = openstack_vcr.service

    net_openstack_vcr = OpenStackVCR.new(
      :vcr_directory  => spec_data_folder,
      :project_scoped => true,
      :service_class  => Fog::OpenStack::Network
    )
    @network_service = net_openstack_vcr.service
  end

  it 'CRUD & list shares' do
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

  it 'CRUD & list share_snapshots' do
    VCR.use_cassette('share_snap_crud') do
      share_protocol            = 'NFS'
      share_size                = 1
      share_name                = 'fog_share'
      share_net_name            = 'fog_share_net'
      snap_name                 = 'fog_snap'
      snap_updated_name         = 'fog_snap_updated'

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
          :share_network_id => share_network.id
        )

        example_share.wait_for { ready? }

        # create snapshot
        snap = @service.snapshots.create(
          :share_id => example_share.id,
          :name     => snap_name
        )

        snap.name.must_equal snap_name
        snap_id = snap.id
        snap.wait_for { ready? }

        # get by ID
        snap_by_id = @service.snapshots.find_by_id snap_id
        snap_by_id.wont_equal nil
        snap_by_id.name.must_equal snap_name

        # update name via display_name
        snap_by_id.update(:display_name => snap_updated_name)
        snap_by_id.reload.name.must_equal snap_updated_name

        # get by filtering list by name
        snaps = @service.snapshots.all(:name => snap_updated_name)
        snaps.length.must_equal 1
        snaps.first.id.must_equal snap_id
      ensure
        # delete the snapshot(s)
        @service.snapshots.all(:name => snap_updated_name).each(&:destroy)
        # check delete action
        @service.snapshots.all(:name => snap_updated_name).each do |s|
          s.status.must_equal 'deleting'
        end

        # only can go on when the snapshots are gone
        Fog.wait_for do
          begin
            snaps = @service.snapshots.all(:name => snap_updated_name)
            snaps.length.zero?
          end
        end

        # delete the share(s)
        @service.shares.all(:name => share_name).each(&:destroy)

        # only can go on when the shares are gone
        Fog.wait_for do
          begin
            shares = @service.shares.all(:name => share_name)
            shares.length.zero?
          end
        end

        # delete the share network(s)
        @service.networks.all(:name => share_net_name).each(&:destroy)
      end
    end
  end

  it 'acts on shares' do
    VCR.use_cassette('share_actions') do
      share_protocol    = 'NFS'
      share_size_small  = 1
      share_size_big    = 2
      share_name        = 'fog_share_action'
      share_net_name    = 'fog_share_action_net'
      share_access_type = 'ip'

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
        share = @service.shares.create(
          :share_proto      => share_protocol,
          :size             => share_size_small,
          :name             => share_name,
          :share_network_id => share_network.id
        )
        share.wait_for { ready? }

        # modify share sizes
        share.size.must_equal share_size_small
        share.extend(share_size_big)
        share.wait_for { ready? }
        share.size.must_equal share_size_big
        share.shrink(share_size_small)
        share.wait_for { ready? }
        share.size.must_equal share_size_small

        # modify share access
        share.access_rules.length.must_equal 0
        access_rule = share.access_rules.create(
          :access_type  => share_access_type,
          :access_to    => '10.0.0.2',
          :access_level => 'ro'
        )
        rules = share.access_rules
        rules.length.must_equal 1
        new_rule = rules.first
        new_rule.wait_for { ready? }
        new_rule.access_type.must_equal share_access_type
        new_rule.id.must_equal access_rule.id
        share.revoke_access(access_rule.id)
        Fog.wait_for { share.access_rules.empty? }
      ensure
        # delete the share(s)
        @service.shares.all(:name => share_name).each(&:destroy)

        # only can go on when the shares are gone
        Fog.wait_for do
          begin
            shares = @service.shares.all(:name => share_name)
            shares.length.zero?
          end
        end

        # delete the share network(s)
        @service.networks.all(:name => share_net_name).each(&:destroy)
      end
    end
  end
end
