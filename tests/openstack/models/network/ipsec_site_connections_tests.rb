Shindo.tests("Fog::Network[:openstack] | ipsec_site_connections", ['openstack']) do
  params = {:name           => 'test-ipsec-site-connection',
            :vpnservice_id  => 'vpn',
            :ikepolicy_id   => 'ike',
            :ipsecpolicy_id => 'ipsec',
            :description    => 'Test VPN IPSec Site Connection',
            :tenant_id      => 'tenant_id',
            :peer_address   => "172.24.4.226",
            :peer_id        => "172.24.4.226",
            :peer_cidrs     => [],
            :psk            => "secret",
            :mtu            => 1500,
            :dpd            => {"action" => "hold", "interval" => 30, "timeout" => 120},
            :initiator      => "bi-directional",
            :admin_state_up => true}

  @ipsec_site_connection = Fog::Network[:openstack].ipsec_site_connections.create(params)

  @ipsec_site_connections = Fog::Network[:openstack].ipsec_site_connections

  tests('success') do
    tests('#all').succeeds do
      @ipsec_site_connections.all
    end

    tests('#get').succeeds do
      @ipsec_site_connections.get(@ipsec_site_connection.id)
    end
  end

  @ipsec_site_connection.destroy
end
