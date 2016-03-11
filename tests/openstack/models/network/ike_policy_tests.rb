Shindo.tests("Fog::Network[:openstack] | ike_policy", ['openstack']) do
  tests('success') do
    tests('#create').succeeds do
      @instance = Fog::Network[:openstack].ike_policies.create(:name                    => 'test-ike-policy',
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
                                                               :ike_version             => 'v1')
      !@instance.id.nil?
    end

    tests('#update').succeeds do
      @instance.name                 = 'rename-test-ike-policy'
      @instance.description          = 'Test VPN IKE Policy'
      @instance.tenant_id            = 'baz'
      @instance.auth_algorithm       = 'sha512'
      @instance.encryption_algorithm = 'aes-512'
      @pfs                           = 'group1'
      @phase1_negotiation_mode       = 'main'
      @ike_version                   = 'v1'
      @lifetime                      = {'units' => 'seconds', 'value' => 3600}
      @instance.update
    end

    tests('#destroy').succeeds do
      @instance.destroy == true
    end
  end
end
