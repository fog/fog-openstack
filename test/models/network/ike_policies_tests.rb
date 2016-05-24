require "test_helper"

describe "Fog::Network[:openstack] | ike_policies" do
  before do
    @ike_policy = Fog::Network[:openstack].ike_policies.create(
      :name                    => 'test-ike-policy',
      :description             => 'Test VPN IKE Policy',
      :tenant_id               => 'tenant_id',
      :auth_algorithm          => 'sha1',
      :encryption_algorithm    => 'aes-256',
      :pfs                     => 'group5',
      :phase1_negotiation_mode => 'main',
      :lifetime                => {
        'units' => 'seconds',
        'value' => 3600
      },
      :ike_version             => 'v1'
    )

    @ike_policies = Fog::Network[:openstack].ike_policies
  end

  describe "success" do
    it "#all" do
      @ike_policies.all[0].description.must_equal "Test VPN IKE Policy"
    end

    it "#get" do
      @ike_policies.get(@ike_policy.id).name.must_equal 'test-ike-policy'
    end
  end

  after do
    @ike_policy.destroy
  end
end
