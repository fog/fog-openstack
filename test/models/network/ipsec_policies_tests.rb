require "test_helper"
require "helpers/network_helper"

describe "Fog::OpenStack::Network | ipsec_policies" do
  before do
    params = {
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

    @ipsec_policy = network.ipsec_policies.create(params)
    @ipsec_policies = network.ipsec_policies
  end

  after do
    @ipsec_policy.destroy
  end

  describe "success" do
    it "#all" do
      @ipsec_policies.all[0].description.must_equal 'Test VPN ipsec Policy'
    end

    it "#get" do
      @ipsec_policies.get(@ipsec_policy.id).name.must_equal "test-ipsec-policy"
    end
  end
end
