require 'test_helper'

describe "Fog::OpenStack::Network | ike_policy requests" do
  describe "success" do
    before do
      @ike_policy_format = {
        'id'                      => String,
        'name'                    => String,
        'description'             => String,
        'tenant_id'               => String,
        'auth_algorithm'          => String,
        'encryption_algorithm'    => String,
        'pfs'                     => String,
        'phase1_negotiation_mode' => String,
        'lifetime'                => Hash,
        'ike_version'             => String
      }

      attributes = {
        :name                    => 'test-ike-policy',
        :description             => 'Test VPN IKE Policy',
        :tenant_id               => 'tenant_id',
        :auth_algorithm          => 'sha1',
        :encryption_algorithm    => 'aes-256',
        :pfs                     => 'group5',
        :phase1_negotiation_mode => 'main',
        :lifetime                => {'units' => 'seconds', 'value' => 3600},
        :ike_version             => 'v1'
      }

      @ike_policy = network.create_ike_policy(attributes).body
    end

    it "#create_ike_policy" do
      @ike_policy.must_match_schema('ikepolicy' => @ike_policy_format)
    end

    it "#list_ike_policies" do
      network.list_ike_policies.body.
        must_match_schema('ikepolicies' => [@ike_policy_format])
    end

    it "#get_ike_policy" do
      ike_policy_id = network.ike_policies.all.first.id
      network.get_ike_policy(ike_policy_id).body.
        must_match_schema('ikepolicy' => @ike_policy_format)
    end

    it "#update_ike_policy" do
      ike_policy_id = network.ike_policies.all.first.id
      attributes = {
        :name                    => 'rename-test-ike-policy',
        :description             => 'Test VPN IKE Policy',
        :tenant_id               => 'tenant_id',
        :auth_algorithm          => 'sha1',
        :encryption_algorithm    => 'aes-256',
        :pfs                     => 'group5',
        :phase1_negotiation_mode => 'main',
        :lifetime                => {'units' => 'seconds', 'value' => 3600},
        :ike_version             => 'v1'
      }

      network.update_ike_policy(ike_policy_id, attributes).body.
        must_match_schema('ikepolicy' => @ike_policy_format)
    end

    it "#delete_ike_policy" do
      ike_policy_id = network.ike_policies.all.first.id
      network.delete_ike_policy(ike_policy_id).status.must_equal 204
    end
  end

  describe "failure" do
    it "#get_ike_policy" do
      proc do
        network.get_ike_policy(0)
      end.must_raise Fog::OpenStack::Network::NotFound
    end

    it "#update_ike_policy" do
      proc do
        network.update_ike_policy(0, {})
      end.must_raise Fog::OpenStack::Network::NotFound
    end

    it "#delete_ike_policy" do
      proc do
        network.delete_ike_policy(0)
      end.must_raise Fog::OpenStack::Network::NotFound
    end
  end
end
