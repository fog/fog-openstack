Shindo.tests("Fog::Network[:openstack] | ipsec_policy", ['openstack']) do
  tests('success') do
    tests('#create').succeeds do
      @instance = Fog::Network[:openstack].ipsec_policies.create(:name                 => 'test-ipsec-policy',
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
                                                                 :encapsulation_mode   => 'tunnel')
      !@instance.id.nil?
    end

    tests('#update').succeeds do
      @instance.name                 = 'rename-test-ipsec-policy'
      @instance.description          = 'Test VPN ipsec Policy'
      @instance.tenant_id            = 'baz'
      @instance.auth_algorithm       = 'sha27'
      @instance.encryption_algorithm = 'aes-18'
      @instance.pfs                  = 'group52'
      @instance.transform_protocol   = 'espn'
      @instance.encapsulation_mode   = 'tunnel'
      @instance.lifetime             = {'units' => 'seconds', 'value' => 3600}
      @instance.update
    end

    tests('#destroy').succeeds do
      @instance.destroy == true
    end
  end
end
