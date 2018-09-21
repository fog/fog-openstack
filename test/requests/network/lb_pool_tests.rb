require 'test_helper'

describe "Fog::OpenStack::Network | lb_pool requests" do
  before do
    @lb_pool_format = {
      'id'                 => String,
      'subnet_id'          => String,
      'protocol'           => String,
      'lb_method'          => String,
      'name'               => String,
      'description'        => String,
      'health_monitors'    => Array,
      'members'            => Array,
      'status'             => String,
      'admin_state_up'     => Fog::Boolean,
      'vip_id'             => Fog::Nullable::String,
      'tenant_id'          => String,
      'active_connections' => Fog::Nullable::Integer,
      'bytes_in'           => Fog::Nullable::Integer,
      'bytes_out'          => Fog::Nullable::Integer,
      'total_connections'  => Fog::Nullable::Integer
    }

    @lb_pool_stats_format = {
      'active_connections' => Integer,
      'bytes_in'           => Integer,
      'bytes_out'          => Integer,
      'total_connections'  => Integer
    }
  end

  describe "success" do
    before do
      subnet_id = 'subnet_id'
      protocol = 'HTTP'
      lb_method = 'ROUND_ROBIN'
      attributes = {
        :name           => 'test-pool',
        :description    => 'Test Pool',
        :admin_state_up => true,
        :tenant_id      => 'tenant_id'
      }
      @lb_pool = network.create_lb_pool(subnet_id, protocol, lb_method, attributes).body
    end

    it "#create_lb_pool" do
      @lb_pool.must_match_schema('pool' => @lb_pool_format)
    end

    it "#list_lb_pools" do
      network.list_lb_pools.body.
        must_match_schema('pools' => [@lb_pool_format])
    end

    it "#get_lb_pool" do
      lb_pool_id = network.lb_pools.all.first.id
      network.get_lb_pool(lb_pool_id).body.
        must_match_schema('pool' => @lb_pool_format)
    end

    it "#get_lb_pool_stats" do
      lb_pool_id = network.lb_pools.all.first.id
      network.get_lb_pool_stats(lb_pool_id).body.
        must_match_schema('stats' => @lb_pool_stats_format)
    end

    it "#update_lb_pool" do
      lb_pool_id = network.lb_pools.all.first.id
      attributes = {
        :name           => 'new-test-pool',
        :description    => 'New Test Pool',
        :lb_method      => 'LEAST_CONNECTIONS',
        :admin_state_up => false
      }
      network.update_lb_pool(lb_pool_id, attributes).body.
        must_match_schema('pool' => @lb_pool_format)
    end

    it "#delete_lb_pool" do
      lb_pool_id = network.lb_pools.all.first.id
      network.delete_lb_pool(lb_pool_id).status.must_equal 204
    end
  end

  describe "failure" do
    it "#get_lb_pool" do
      proc do
        network.get_lb_pool(0)
      end.must_raise Fog::OpenStack::Network::NotFound
    end

    it "#update_lb_pool" do
      proc do
        network.update_lb_pool(0, {})
      end.must_raise Fog::OpenStack::Network::NotFound
    end

    it "#delete_lb_pool" do
      proc do
        network.delete_lb_pool(0)
      end.must_raise Fog::OpenStack::Network::NotFound
    end
  end
end
