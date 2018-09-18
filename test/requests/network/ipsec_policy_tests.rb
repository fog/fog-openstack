require "test_helper"

describe "Fog::OpenStack::Network | ipsec_policy requests" do
  before do
    @ipsec_policy_format = {
      'id'                   => String,
      'name'                 => String,
      'description'          => String,
      'tenant_id'            => String,
      'lifetime'             => Hash,
      'pfs'                  => String,
      'transform_protocol'   => String,
      'auth_algorithm'       => String,
      'encapsulation_mode'   => String,
      'encryption_algorithm' => String
    }
  end

  describe "success" do
    before do
      attributes = {
        :name                 => 'test-ipsec-policy',
        :description          => 'Test VPN ipsec Policy',
        :tenant_id            => 'tenant_id',
        :auth_algorithm       => 'sha1',
        :encryption_algorithm => 'aes-128',
        :pfs                  => 'group5',
        :transform_protocol   => 'esp',
        :lifetime             => {'units' => 'seconds', 'value' => 3600},
        :encapsulation_mode   => 'tunnel'
      }

      @create_ipsec_policy = network.create_ipsec_policy(attributes).body
    end

    it "#create_ipsec_policy" do
      @create_ipsec_policy.must_match_schema('ipsecpolicy' => @ipsec_policy_format)
    end

    it "#list_ipsec_policies" do
      network.list_ipsec_policies.body.
        must_match_schema('ipsecpolicies' => [@ipsec_policy_format])
    end

    it "#get_ipsec_policy" do
      ipsec_policy_id = network.ipsec_policies.all.first.id
      network.get_ipsec_policy(ipsec_policy_id).body.
        must_match_schema('ipsecpolicy' => @ipsec_policy_format)
    end

    it "#update_ipsec_policy" do
      ipsec_policy_id = network.ipsec_policies.all.first.id
      attributes = {
        :name                 => 'rename-test-ipsec-policy',
        :description          => 'Test VPN ipsec Policy',
        :tenant_id            => 'tenant_id',
        :auth_algorithm       => 'sha1',
        :encryption_algorithm => 'aes-128',
        :pfs                  => 'group5',
        :transform_protocol   => 'esp',
        :lifetime             => {'units' => 'seconds', 'value' => 3600},
        :encapsulation_mode   => 'tunnel'
      }

      network.update_ipsec_policy(ipsec_policy_id, attributes).body.
        must_match_schema('ipsecpolicy' => @ipsec_policy_format)
    end

    it "#delete_ipsec_policy" do
      ipsec_policy_id = network.ipsec_policies.all.first.id
      network.delete_ipsec_policy(ipsec_policy_id).status.must_equal 204
    end
  end

  describe "failure" do
    it "#get_ipsec_policy" do
      proc do
        network.get_ipsec_policy(0)
      end.must_raise Fog::OpenStack::Network::NotFound
    end

    it "#update_ipsec_policy" do
      proc do
        network.update_ipsec_policy(0, {})
      end.must_raise Fog::OpenStack::Network::NotFound
    end

    it "#delete_ipsec_policy" do
      proc do
        network.delete_ipsec_policy(0)
      end.must_raise Fog::OpenStack::Network::NotFound
    end
  end
end
