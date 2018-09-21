require 'test_helper'

describe "Fog::OpenStack::Network | ipsec_site_connection requests" do
  before do
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
  end

  describe "success" do
    before do
      vpnservice_id  = "vpn"
      ikepolicy_id   = "ike"
      ipsecpolicy_id = "ipsec"

      attributes = {
        :name           => 'test-ipsec-site-connection',
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

      @ipsec_site_connection = network.create_ipsec_site_connection(
        vpnservice_id, ikepolicy_id,
        ipsecpolicy_id, attributes
      ).body
    end

    it "#create_ipsec_site_connection" do
      @ipsec_site_connection.must_match_schema(
        'ipsec_site_connection' => @ipsec_site_connection_format
      )
    end

    it "#list_ipsec_site_connections" do
      network.list_ipsec_site_connections.body.
        must_match_schema('ipsec_site_connections' => [@ipsec_site_connection_format])
    end

    it "#get_ipsec_site_connection" do
      ipsec_site_connection_id = network.ipsec_site_connections.all.first.id
      network.get_ipsec_site_connection(ipsec_site_connection_id).body.
        must_match_schema('ipsec_site_connection' => @ipsec_site_connection_format)
    end

    it "#update_ipsec_site_connection" do
      ipsec_site_connection_id = network.ipsec_site_connections.all.first.id

      attributes = {
        :name           => 'rename-test-ipsec-site-connection',
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

      network.update_ipsec_site_connection(ipsec_site_connection_id, attributes).body.
        must_match_schema('ipsec_site_connection' => @ipsec_site_connection_format)
    end

    it "#delete_ipsec_site_connection" do
      ipsec_site_connection_id = network.ipsec_site_connections.all.first.id
      network.delete_ipsec_site_connection(ipsec_site_connection_id).status.must_equal 204
    end
  end

  describe "failure" do
    it "#get_ipsec_site_connection" do
      proc do
        network.get_ipsec_site_connection(0)
      end.must_raise Fog::OpenStack::Network::NotFound
    end

    it "#update_ipsec_site_connection" do
      proc do
        network.update_ipsec_site_connection(0, {})
      end.must_raise Fog::OpenStack::Network::NotFound
    end

    it "#delete_ipsec_site_connection" do
      proc do
        network.delete_ipsec_site_connection(0)
      end.must_raise Fog::OpenStack::Network::NotFound
    end
  end
end
