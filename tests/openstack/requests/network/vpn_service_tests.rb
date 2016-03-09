Shindo.tests('Fog::Network[:openstack] | vpn_service requests', ['openstack']) do
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

  tests('success') do
    tests('#create_vpn_service').formats('vpnservice' => @vpn_service_format) do
      subnet_id = 'subnet_id'
      router_id = 'router_id'

      attributes = {:name => 'test-vpn-service', :description => 'Test VPN Service',
                    :admin_state_up => true, :tenant_id => 'tenant_id'}
      Fog::Network[:openstack].create_vpn_service(subnet_id, router_id, attributes).body
    end

    tests('#list_vpn_services').formats('vpnservices' => [@vpn_service_format]) do
      Fog::Network[:openstack].list_vpn_services.body
    end

    tests('#get_vpn_service').formats('vpnservice' => @vpn_service_format) do
      vpn_service_id = Fog::Network[:openstack].vpn_services.all.first.id
      Fog::Network[:openstack].get_vpn_service(vpn_service_id).body
    end

    tests('#update_vpn_service').formats('vpnservice' => @vpn_service_format) do
      vpn_service_id = Fog::Network[:openstack].vpn_services.all.first.id
      attributes = {:name => 'renamed-test-vpn-service', :description => 'Test VPN Service',
                    :admin_state_up => true, :tenant_id => 'tenant_id',
                    :subnet_id => 'subnet_id', :router_id => 'router_id'}
      Fog::Network[:openstack].update_vpn_service(vpn_service_id, attributes).body
    end

    tests('#delete_vpn_service').succeeds do
      vpn_servcice_id = Fog::Network[:openstack].vpn_services.all.first.id
      Fog::Network[:openstack].delete_vpn_service(vpn_servcice_id)
    end
  end

  tests('failure') do
    tests('#get_vpn_service').raises(Fog::Network::OpenStack::NotFound) do
      Fog::Network[:openstack].get_vpn_service(0)
    end

    tests('#update_lb_pool').raises(Fog::Network::OpenStack::NotFound) do
      Fog::Network[:openstack].update_lb_pool(0, {})
    end

    tests('#delete_vpn_service').raises(Fog::Network::OpenStack::NotFound) do
      Fog::Network[:openstack].delete_vpn_service(0)
    end
  end
end
