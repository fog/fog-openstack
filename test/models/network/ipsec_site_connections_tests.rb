require "test_helper"
require "helpers/network_helper"

describe "Fog::OpenStack::Network | ipsec_site_connections" do
  before do
    params = {
      :name           => 'test-ipsec-site-connection',
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
      :admin_state_up => true
    }

    @ipsec_site_connection = network.ipsec_site_connections.create(params)
    @ipsec_site_connections = network.ipsec_site_connections
  end

  after do
    @ipsec_site_connection.destroy
  end

  describe "success" do
    it "#all" do
      @ipsec_site_connections.all[0].status.must_equal "ACTIVE"
    end

    it "#get" do
      @ipsec_site_connections.get(@ipsec_site_connection.id).status.must_equal "ACTIVE"
    end
  end
end
