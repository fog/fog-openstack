require 'test_helper'

describe "Fog::Network[:openstack] | network requests" do
  before do
    @network_format = {
      'id'              => String,
      'name'            => String,
      'subnets'         => Array,
      'shared'          => Fog::Boolean,
      'status'          => String,
      'admin_state_up'  => Fog::Boolean,
      'tenant_id'       => String
    }

    @network_format_extensions = {
      'router:external'           => Fog::Boolean,
      'provider:network_type'     => String,
      'provider:physical_network' => Fog::Nullable::String,
      'provider:segmentation_id'  => Integer
    }

    @network = Fog::Network[:openstack]
  end

  describe "success" do
    before do
      attributes = {
        :name => 'net_name',
        :shared => false,
        :admin_state_up => true,
        :tenant_id => 'tenant_id'
      }
      @network_create = @network.create_network(attributes).body
    end

    it "#create_network" do
      @network_create.must_match_schema('network' => @network_format)
    end

    it "#create_network+provider extensions" do
      attributes = {
        :name                     => 'net_name',
        :shared                   => false,
        :admin_state_up           => true,
        :tenant_id                => 'tenant_id',
        :router_external          => true,
        # local, gre, vlan. Depends on the provider.
        # May rise an exception if the network_type isn't valid:
        # QuantumError: "Invalid input for operation: provider:physical_network"
        :provider_network_type    => 'gre',
        :provider_segmentation_id => 22,
      }

      @network.create_network(attributes).body.
        must_match_schema( {'network' => @network_format.merge(@network_format_extensions)})
    end

    it "#list_networks" do
      @network.list_networks.body.
        must_match_schema('networks' => [@network_format])
    end

    it "#get_network" do
      network_id = @network.networks.all.first.id
      @network.get_network(network_id).body.
        must_match_schema('network' => @network_format)
    end

    it "#update_network" do
      network_id = @network.networks.all.first.id
      attributes = {:name => 'net_name', :shared => false,
                    :admin_state_up => true}
      @network.update_network(network_id, attributes).body.
        must_match_schema('network' => @network_format)
    end

    it "#delete_network" do
      network_id = @network.networks.all.first.id
      @network.delete_network(network_id).status.must_equal 204
    end
  end

  describe "failure" do
    it "#create_network+provider extensions" do
      skip if Fog.mocking?
      proc do
        attributes = {
          :name                     => 'net_name',
          :shared                   => false,
          :admin_state_up           => true,
          :tenant_id                => 'tenant_id',
          :router_external          => true,
          # local, gre, vlan. Depends on the provider.
          # May rise an exception if the network_type isn't valid:
          # QuantumError: "Invalid input for operation: provider:physical_network"
          :provider_network_type    => 'foobar',
          :provider_segmentation_id => 22,
        }

        @network.create_network(attributes)
      end.must_raise(Excon::Errors::BadRequest)
    end

    it "#get_network" do
      proc do
        @network.get_network(0)
      end.must_raise Fog::Network::OpenStack::NotFound
    end

    it "#update_network" do
      proc do
        @network.update_network(0, {})
      end.must_raise Fog::Network::OpenStack::NotFound
    end

    it "#delete_network" do
      proc do
        @network.delete_network(0)
      end.must_raise Fog::Network::OpenStack::NotFound
    end
  end

  after do
    @network.networks.each do |n|
      @network.delete_network(n.id)
    end
  end
end
