require 'test_helper'

describe "Fog::OpenStack::Network | subnet requests" do
  before do
    @subnet_format = {
      'id'               => String,
      'name'             => String,
      'network_id'       => String,
      'cidr'             => String,
      'ip_version'       => Integer,
      'gateway_ip'       => String,
      'allocation_pools' => Array,
      'dns_nameservers'  => Array,
      'host_routes'      => Array,
      'enable_dhcp'      => Fog::Boolean,
      'tenant_id'        => String
    }
  end

  describe "success" do
    before do
      network_id = 'net_id'
      cidr = '10.2.2.0/24'
      ip_version = 4
      attributes = {
        :name             => 'subnet_name',
        :gateway_ip       => '10.2.2.1',
        :allocation_pools => [],
        :dns_nameservers  => [],
        :host_routes      => [],
        :enable_dhcp      => true,
        :tenant_id        => 'tenant_id'
      }
      @subnet = network.create_subnet(network_id, cidr, ip_version, attributes).body
    end
    it "#create_subnet" do
      @subnet.must_match_schema('subnet' => @subnet_format)
    end

    it "#list_subnet" do
      network.list_subnets.body.must_match_schema('subnets' => [@subnet_format])
    end

    it "#get_subnet" do
      subnet_id = network.subnets.all.first.id
      network.get_subnet(subnet_id).body.must_match_schema('subnet' => @subnet_format)
    end

    it "#update_subnet" do
      subnet_id = network.subnets.all.first.id
      attributes = {
        :name             => 'subnet_name',
        :gateway_ip       => '10.2.2.1',
        :allocation_pools => [],
        :dns_nameservers  => [],
        :host_routes      => [],
        :enable_dhcp      => true
      }

      network.update_subnet(subnet_id, attributes).body.must_match_schema('subnet' => @subnet_format)
    end

    it "#delete_subnet" do
      subnet_id = network.subnets.all.first.id
      network.delete_subnet(subnet_id).status.must_equal 204
    end
  end

  describe "failure" do
    it "#get_subnet" do
      proc do
        network.get_subnet(0)
      end.must_raise Fog::OpenStack::Network::NotFound
    end

    it "#update_subnet" do
      proc do
        network.update_subnet(0, {})
      end.must_raise Fog::OpenStack::Network::NotFound
    end

    it "#delete_subnet" do
      proc do
        network.delete_subnet(0)
      end.must_raise Fog::OpenStack::Network::NotFound
    end
  end
end
