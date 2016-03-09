Shindo.tests('Fog::Network[:openstack] | ipsec_site_connection requests', ['openstack']) do
  @ipsec_site_connection_format = {
    'id'                => String,
    'name'              => String,
    'description'       => String,
    'status'            => String,
    'tenant_id'         => String,
    'admin_state_up'    => Fog::Boolean,
    'psk'               => String,
    'initiator'         => String,
    'auth_mode'         => String,
    'peer_cidrs'        => Array,
    'mtu'               => Integer,
    'peer_ep_group_id'  => String,
    'ikepolicy_id'      => String,
    'vpnservice_id'     => String,
    'dpd'               => Hash,
    'route_mode'        => String,
    'ipsecpolicy_id'    => String,
    'local_ep_group_id' => String,
    'peer_address'      => String,
    'peer_id'           => String
  }

  tests('success') do
    tests('#create_ipsec_site_connection').formats('ipsec_site_connection' => @ipsec_site_connection_format) do
      vpnservice_id = "vpn"
      ikepolicy_id = "ike"
      ipsecpolicy_id = "ipsec"

      attributes = {:name => 'test-ipsec-site-connection', :description => 'Test VPN IPSec Site Connection',
                    :tenant_id => 'tenant_id',
                    :peer_address => "172.24.4.226", :peer_id => "172.24.4.226", :peer_cidrs => [],
                    :psk => "secret", :mtu => 1500, :dpd => {"action" => "hold", "interval" => 30, "timeout" => 120},
                    :initiator => "bi-directional", :admin_state_up => true
                  }
      Fog::Network[:openstack].create_ipsec_site_connection(vpnservice_id,
                                                            ikepolicy_id,
                                                            ipsecpolicy_id,
                                                            attributes).body
    end

    tests('#list_ipsec_site_connections').formats('ipsec_site_connections' => [@ipsec_site_connection_format]) do
      Fog::Network[:openstack].list_ipsec_site_connections.body
    end

    tests('#get_ipsec_site_connection').formats('ipsec_site_connection' => @ipsec_site_connection_format) do
      ipsec_site_connection_id = Fog::Network[:openstack].ipsec_site_connections.all.first.id
      Fog::Network[:openstack].get_ipsec_site_connection(ipsec_site_connection_id).body
    end

    tests('#update_ipsec_site_connection').formats('ipsec_site_connection' => @ipsec_site_connection_format) do
      ipsec_site_connection_id = Fog::Network[:openstack].ipsec_site_connections.all.first.id

      attributes = {:name => 'rename-test-ipsec-site-connection', :description => 'Test VPN IPSec Site Connection',
                    :tenant_id => 'tenant_id',
                    :peer_address => "172.24.4.226", :peer_id => "172.24.4.226", :peer_cidrs => [],
                    :psk => "secret", :mtu => 1500, :dpd => {"action" => "hold", "interval" => 30, "timeout" => 120},
                    :initiator => "bi-directional", :admin_state_up => true}
      Fog::Network[:openstack].update_ipsec_site_connection(ipsec_site_connection_id, attributes).body
    end

    tests('#delete_ipsec_site_connection').succeeds do
      ipsec_site_connection_id = Fog::Network[:openstack].ipsec_site_connections.all.first.id
      Fog::Network[:openstack].delete_ipsec_site_connection(ipsec_site_connection_id)
    end
  end

  tests('failure') do
    tests('#get_ipsec_site_connection').raises(Fog::Network::OpenStack::NotFound) do
      Fog::Network[:openstack].get_ipsec_site_connection(0)
    end

    tests('#update_ipsec_site_connection').raises(Fog::Network::OpenStack::NotFound) do
      Fog::Network[:openstack].update_ipsec_site_connection(0, {})
    end

    tests('#delete_ipsec_site_connection').raises(Fog::Network::OpenStack::NotFound) do
      Fog::Network[:openstack].delete_ipsec_site_connection(0)
    end
  end
end
