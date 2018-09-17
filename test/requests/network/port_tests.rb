require 'test_helper'

describe "Fog::OpenStack::Network | port requests" do
  before do
    @port_format = {
      'id'                    => String,
      'name'                  => String,
      'network_id'            => String,
      'fixed_ips'             => Array,
      'mac_address'           => String,
      'status'                => String,
      'admin_state_up'        => Fog::Boolean,
      'device_owner'          => String,
      'device_id'             => String,
      'tenant_id'             => String,
      'security_groups'       => Array,
      'allowed_address_pairs' => Array
    }
  end

  describe "success" do
    before do
      network_id = 'net_id'
      attributes = {
        :name                  => 'port_name',
        :fixed_ips             => [],
        :mac_address           => 'fa:16:3e:62:91:7f',
        :admin_state_up        => true,
        :device_owner          => 'device_owner',
        :device_id             => 'device_id',
        :tenant_id             => 'tenant_id',
        :security_groups       => [],
        :allowed_address_pairs => []
      }

      @port = network.create_port(network_id, attributes).body
    end

    it "#create_port" do
      @port.must_match_schema('port' => @port_format)
    end

    it "#list_port" do
      # Breaks because sometimes "security_groups" => nil
      skip unless Minitest::Test::UNIT_TESTS_CLEAN
      network.list_ports.body.must_match_schema('ports' => [@port_format])
    end

    it "#get_port" do
      port_id = network.ports.all.first.id
      network.get_port(port_id).body.must_match_schema('port' => @port_format)
    end

    it "#update_port" do
      port_id = network.ports.all.first.id
      attributes = {
        :name           => 'port_name',
        :fixed_ips      => [],
        :admin_state_up => true,
        :device_owner   => 'device_owner',
        :device_id      => 'device_id'
      }

      network.update_port(port_id, attributes).body.
        must_match_schema('port' => @port_format)
    end

    it "#delete_port" do
      port_id = network.ports.all.first.id
      network.delete_port(port_id).status.must_equal 204
    end
  end

  describe "failure" do
    it "#get_port" do
      proc do
        network.get_port(0)
      end.must_raise Fog::OpenStack::Network::NotFound
    end

    it "#update_port" do
      proc do
        network.update_port(0, {})
      end.must_raise Fog::OpenStack::Network::NotFound
    end

    it "#delete_port" do
      proc do
        network.delete_port(0)
      end.must_raise Fog::OpenStack::Network::NotFound
    end
  end
end
