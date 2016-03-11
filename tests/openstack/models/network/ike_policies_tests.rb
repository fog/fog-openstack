Shindo.tests("Fog::Network[:openstack] | ike_policies", ['openstack']) do
  @ike_policy = Fog::Network[:openstack].ike_policies.create(:name                    => 'test-ike-policy',
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

  @ike_policies = Fog::Network[:openstack].ike_policies

  tests('success') do
    tests('#all').succeeds do
      @ike_policies.all
    end

    tests('#get').succeeds do
      @ike_policies.get(@ike_policy.id)
    end
  end

  @ike_policy.destroy
end
