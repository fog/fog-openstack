require 'test_helper'

describe "Fog::OpenStack::Network | router requests" do
  before do
    @router_format = {
      :id                    => String,
      :name                  => String,
      :status                => String,
      :admin_state_up        => Fog::Boolean,
      :tenant_id             => String,
      :external_gateway_info => Fog::Nullable::Hash
    }
  end

  describe "success" do
    before do
      attributes = {
        :admin_state_up => true,
        :tenant_id      => 'tenant_id'
      }

      @router = network.create_router('router_name', attributes).body
    end

    it "#create_router" do
      @router.must_match_schema('router' => @router_format)
    end

    it "#list_routers" do
      network.list_routers.body.must_match_schema('routers' => [@router_format])
    end

    it "#get_router" do
      router_id = network.routers.all.first.id
      network.get_router(router_id).body.must_match_schema('router' => @router_format)
    end

    it "#update_router" do
      router_id = network.routers.all.first.id
      attributes = {
        :name                  => 'net_name',
        :external_gateway_info => {:network_id => 'net_id'},
        :status                => 'ACTIVE',
        :admin_state_up        => true
      }
      network.update_router(router_id, attributes).body.must_match_schema('router' => @router_format)
    end

    it "#update_router_with_network" do
      router_id = network.routers.all.first.id
      net = network.networks.first
      attributes = {
        :name                  => 'net_name',
        :external_gateway_info => net,
        :status                => 'ACTIVE',
        :admin_state_up        => true
      }

      network.update_router(router_id, attributes).body.must_match_schema('router' => @router_format)
    end

    it "#delete_router" do
      router_id = network.routers.all.last.id
      network.delete_router(router_id).status.must_equal 204
    end
  end

  describe "failure" do
    it "#get_router" do
      proc do
        network.get_router(0)
      end.must_raise Fog::OpenStack::Network::NotFound
    end

    it "#update_router" do
      proc do
        network.update_router(0, {})
      end.must_raise Fog::OpenStack::Network::NotFound
    end

    it "#delete_router" do
      proc do
        network.delete_router(0)
      end.must_raise Fog::OpenStack::Network::NotFound
    end
  end
end
