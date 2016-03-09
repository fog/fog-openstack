Shindo.tests("Fog::Network[:openstack] | ipsec_policies", ['openstack']) do
  params = {:name                 => 'test-ipsec-policy',
            :description          => 'Test VPN ipsec Policy',
            :tenant_id            => 'tenant_id',
            :auth_algorithm       => 'sha1',
            :encryption_algorithm => 'aes-128',
            :pfs                  => 'group5',
            :transform_protocol   => 'esp',
            :lifetime             => {'units' => 'seconds', 'value' => 3600},
            :encapsulation_mode   => 'tunnel'}
  @ipsec_policy = Fog::Network[:openstack].ipsec_policies.create(params)

  @ipsec_policies = Fog::Network[:openstack].ipsec_policies

  tests('success') do
    tests('#all').succeeds do
      @ipsec_policies.all
    end

    tests('#get').succeeds do
      @ipsec_policies.get(@ipsec_policy.id)
    end
  end

  @ipsec_policy.destroy
end
