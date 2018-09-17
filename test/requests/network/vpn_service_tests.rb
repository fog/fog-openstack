require 'test_helper'

describe "Fog::OpenStack::Network | vpn_service requests" do
  before do
    @vpn_service_format = {
      'id'             => String,
      'subnet_id'      => String,
      'router_id'      => String,
      'name'           => String,
      'description'    => String,
      'status'         => String,
      'admin_state_up' => Fog::Boolean,
      'tenant_id'      => String,
      'external_v4_ip' => String,
      'external_v6_ip' => String
    }
  end

  describe "success" do
    before do
      subnet_id = 'subnet_id'
      router_id = 'router_id'

      attributes = {
        :name           => 'test-vpn-service',
        :description    => 'Test VPN Service',
        :admin_state_up => true,
        :tenant_id      => 'tenant_id'
      }

      @vpn_service = network.create_vpn_service(subnet_id, router_id, attributes).body
    end

    it "#create_vpn_service" do
      @vpn_service.must_match_schema('vpnservice' => @vpn_service_format)
    end

    it "#list_vpn_services" do
      network.list_vpn_services.body.must_match_schema('vpnservices' => [@vpn_service_format])
    end

    it "#get_vpn_service" do
      vpn_service_id = network.vpn_services.all.first.id
      network.get_vpn_service(vpn_service_id).body.must_match_schema('vpnservice' => @vpn_service_format)
    end

    it "#update_vpn_service" do
      vpn_service_id = network.vpn_services.all.first.id
      attributes = {
        :name           => 'renamed-test-vpn-service',
        :description    => 'Test VPN Service',
        :admin_state_up => true,
        :tenant_id      => 'tenant_id',
        :subnet_id      => 'subnet_id',
        :router_id      => 'router_id'
      }

      network.update_vpn_service(vpn_service_id, attributes).body.must_match_schema('vpnservice' => @vpn_service_format)
    end

    it "#delete_vpn_service" do
      vpn_servcice_id = network.vpn_services.all.first.id
      network.delete_vpn_service(vpn_servcice_id).status.must_equal 204
    end
  end

  describe "failure" do
    it "#get_vpn_service" do
      proc do
        network.get_vpn_service(0)
      end.must_raise Fog::OpenStack::Network::NotFound
    end

    it "#update_lb_pool" do
      proc do
        network.update_lb_pool(0, {})
      end.must_raise Fog::OpenStack::Network::NotFound
    end

    it "#delete_vpn_service" do
      proc do
        network.delete_vpn_service(0)
      end.must_raise Fog::OpenStack::Network::NotFound
    end
  end
end
