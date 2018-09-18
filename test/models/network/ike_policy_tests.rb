require "test_helper"
require "helpers/network_helper"

describe "Fog::OpenStack::Network | ike_policy" do
  describe "success" do
    before do
      @instance = network.ike_policies.create(
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
    end

    it "#create" do
      @instance.id.wont_be_nil
    end

    it "#update" do
      @instance.name                 = 'rename-test-ike-policy'
      @instance.description          = 'Test VPN IKE Policy'
      @instance.tenant_id            = 'baz'
      @instance.auth_algorithm       = 'sha512'
      @instance.encryption_algorithm = 'aes-512'
      @pfs                           = 'group1'
      @phase1_negotiation_mode       = 'main'
      @ike_version                   = 'v1'
      @lifetime                      = {'units' => 'seconds', 'value' => 3600}
      @instance.update.name.must_equal "rename-test-ike-policy"
    end

    it "#destroy" do
      @instance.destroy.must_equal true
    end
  end
end
