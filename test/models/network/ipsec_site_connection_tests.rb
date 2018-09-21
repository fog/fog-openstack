require "test_helper"
require "helpers/network_helper"

describe "Fog::OpenStack::Network | ipsec_site_connection" do
  describe "success" do
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
        :dpd            => {
          "action"   => "hold",
          "interval" => 30,
          "timeout"  => 120
        },
        :initiator      => "bi-directional",
        :admin_state_up => true
      }
      @instance = network.ipsec_site_connections.create(params)
    end

    it "#create" do
      @instance.id.wont_be_nil
    end

    it "#update" do
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

      @instance.update.name.must_equal "rename-test-ipsec-site-connection"
    end

    it "#destroy" do
      @instance.destroy.must_equal true
    end
  end
end
