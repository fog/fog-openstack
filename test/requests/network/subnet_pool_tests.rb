require 'test_helper'

describe "Fog::OpenStack::Network | subnet_pool requests" do
  before do
    @subnet_pool_format = {
      'id'                => String,
      'name'              => String,
      'prefixes'          => Array,
      'description'       => Fog::Nullable::String,
      'address_scope_id'  => Fog::Nullable::String,
      'shared'            => Fog::Boolean,
      'ip_version'        => Integer,
      'min_prefixlen'     => Integer,
      'max_prefixlen'     => Integer,
      'default_prefixlen' => Integer,
      'is_default'        => Fog::Boolean,
      'default_quota'     => Fog::Nullable::String,
      'created_at'        => String,
      'updated_at'        => String,
      'tenant_id'         => String
    }
  end

  describe "success" do
    before do
      name = 'subnet_pool_name'
      prefixes = ['10.0.0.0/18']
      @subnet_pool = network.create_subnet_pool(name, prefixes).body
    end
    it "#create_subnet_pool" do
      @subnet_pool.must_match_schema('subnetpool' => @subnet_pool_format)
    end

    it "#list_subnet_pool" do
      network.list_subnet_pools.body.must_match_schema('subnetpools' => [@subnet_pool_format])
    end

    it "#get_subnet_pool" do
      subnet_pool_id = network.subnet_pools.all.first.id
      network.get_subnet_pool(subnet_pool_id).body.must_match_schema('subnetpool' => @subnet_pool_format)
    end

    it "#update_subnet_pool" do
      subnet_pool_id = network.subnet_pools.all.first.id
      attributes = {
        :name => 'new_subnet_pool_name'
      }

      network.update_subnet_pool(subnet_pool_id, attributes).body.must_match_schema('subnetpool' => @subnet_pool_format)
    end

    it "#delete_subnet_pool" do
      subnet_pool_id = network.subnet_pools.all.first.id
      network.delete_subnet_pool(subnet_pool_id).status.must_equal 204
    end
  end

  describe "failure" do
    it "#get_subnet_pool" do
      proc do
        network.get_subnet_pool(0)
      end.must_raise Fog::OpenStack::Network::NotFound
    end

    it "#update_subnet_pool" do
      proc do
        network.update_subnet_pool(0, {})
      end.must_raise Fog::OpenStack::Network::NotFound
    end

    it "#delete_subnet_pool" do
      proc do
        network.delete_subnet_pool(0)
      end.must_raise Fog::OpenStack::Network::NotFound
    end
  end
end
