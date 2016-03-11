Shindo.tests("Fog::Network[:openstack] | ipsec_site_connection", ['openstack']) do
  tests('success') do
    tests('#create').succeeds do
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
                :dpd            => {
                  "action"   => "hold",
                  "interval" => 30,
                  "timeout"  => 120
                },
                :initiator      => "bi-directional",
                :admin_state_up => true}
      @instance = Fog::Network[:openstack].ipsec_site_connections.create(params)
      !@instance.id.nil?
    end

    tests('#update').succeeds do
      @instance.name           = 'rename-test-ipsec-site-connection'
      @instance.description    = 'Test VPN IPSec Site Connection'
      @instance.tenant_id      = 'baz'
      @instance.peer_address   = "172.24.4.227"
      @instance.peer_id        = "172.24.4.227"
      @instance.peer_cidrs     = []
      @instance.psk            = "secrets"
      @instance.mtu            = 1600
      @instance.initiator      = "bi-directional"
      @instance.admin_state_up = false
      @instance.dpd            = {
        "action"   => "hold",
        "interval" => 50,
        "timeout"  => 120
      }

      @instance.update
    end

    tests('#destroy').succeeds do
      @instance.destroy == true
    end
  end
end
