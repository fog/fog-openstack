require 'test_helper'
require 'helpers/network_helper.rb'

describe "Fog::OpenStack::Network | network requests" do
  describe "success" do
    let(:network_format) do
      {
        "id"                    => String,
        "subnets"               => Array,
        "status"                => String,
        "name"                  => String,
        "shared"                => Fog::Boolean,
        "admin_state_up"        => Fog::Boolean,
        "qos_policy_id"         => Fog::Nullable::String,
        "port_security_enabled" => Fog::Boolean,
        "tenant_id"             => String,
      }
    end

    let(:network_extentions_format) do
      {
        "router:external"           => Fog::Boolean,
        "provider:network_type"     => String,
        "provider:physical_network" => Fog::Nullable::String,
        "provider:segmentation_id"  => Integer,
      }
    end

    let(:created_network) do
      attributes = {
        :name                  => "net_name1",
        :shared                => false,
        :admin_state_up        => true,
        :tenant_id             => "tenant_id",
        :qos_policy_id         => "qos_policy_id1",
        :port_security_enabled => false
      }
      network.create_network(attributes).body
    end

    before do
      created_network
    end

    it "#create_network" do
      created_network.must_match_schema("network" => network_format)
    end

    it "#create_network+provider extensions" do
      attributes = {
        :name                     => "net_name2",
        :shared                   => false,
        :admin_state_up           => true,
        :tenant_id                => "tenant_id",
        :qos_policy_id            => "qos_policy_id1",
        :port_security_enabled    => false,
        # local, gre, vlan. Depends on the provider.
        # May rise an exception if the network_type isn"t valid:
        # QuantumError: "Invalid input for operation: provider:physical_network"
        :provider_network_type    => "gre",
        :provider_segmentation_id => 22,
        :router_external          => true,
      }

      network.create_network(attributes).body.
        must_match_schema('network' => network_format.merge(network_extentions_format))
    end

    it "#list_networks" do
      network.list_networks.body.
        must_match_schema('networks' => [network_format])
    end

    it "#get_network" do
      network_id = created_network["network"]["id"]
      network.get_network(network_id).body.
        must_match_schema('network' => network_format)
    end

    it "#update_network" do
      attributes = {
        :name                  => 'net_name',
        :shared                => false,
        :admin_state_up        => true,
        :qos_policy_id         => 'new_policy_id',
        :port_security_enabled => true,
        :router_external       => false
      }

      network_id = network.networks.all.first.id
      network_update_extentions_format = {"router:external" => Fog::Boolean}
      network.update_network(network_id, attributes).body.
        must_match_schema('network' => network_format.merge(network_update_extentions_format))
    end

    it "#delete_network" do
      network_id = network.networks.all.first.id
      network.delete_network(network_id).status.must_equal 204
    end
  end

  describe "failure" do
    it "#create_network+provider extensions" do
      unless Fog.mocking?
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

          network.create_network(attributes)
        end.must_raise Excon::Errors::BadRequest
      end
    end

    it "#get_network" do
      proc do
        network.get_network(0)
      end.must_raise Fog::OpenStack::Network::NotFound
    end

    it "#update_network" do
      proc do
        network.update_network(0, {})
      end.must_raise Fog::OpenStack::Network::NotFound
    end

    it "#delete_network" do
      proc do
        network.delete_network(0)
      end.must_raise Fog::OpenStack::Network::NotFound
    end
  end

  after do
    network.networks.each do |n|
      network.delete_network(n.id)
    end
  end
end
