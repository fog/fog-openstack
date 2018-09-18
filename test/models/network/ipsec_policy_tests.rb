require "test_helper"
require "helpers/network_helper"

describe "Fog::OpenStack::Network | ipsec_policy" do
  describe "success" do
    before do
      @instance = network.ipsec_policies.create(
        :name                 => 'test-ipsec-policy',
        :description          => 'Test VPN ipsec Policy',
        :tenant_id            => 'tenant_id',
        :auth_algorithm       => 'sha1',
        :encryption_algorithm => 'aes-128',
        :pfs                  => 'group5',
        :transform_protocol   => 'esp',
        :lifetime             => {
          'units' => 'seconds',
          'value' => 3600
        },
        :encapsulation_mode   => 'tunnel'
      )
    end

    it "#create" do
      @instance.id.wont_be_nil
    end

    it "#update" do
      @instance.name                 = 'rename-test-ipsec-policy'
      @instance.description          = 'Test VPN ipsec Policy'
      @instance.tenant_id            = 'baz'
      @instance.auth_algorithm       = 'sha27'
      @instance.encryption_algorithm = 'aes-18'
      @instance.pfs                  = 'group52'
      @instance.transform_protocol   = 'espn'
      @instance.encapsulation_mode   = 'tunnel'
      @instance.lifetime             = {'units' => 'seconds', 'value' => 3600}
      @instance.update.name.must_equal 'rename-test-ipsec-policy'
    end

    it "#destroy" do
      @instance.destroy.must_equal true
    end
  end
end
