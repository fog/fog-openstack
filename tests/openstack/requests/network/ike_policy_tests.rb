Shindo.tests('Fog::Network[:openstack] | ike_policy requests', ['openstack']) do
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

  tests('success') do
    tests('#create_ike_policy').formats('ikepolicy' => @ike_policy_format) do
      attributes = {:name => 'test-ike-policy', :description => 'Test VPN IKE Policy',
                    :tenant_id => 'tenant_id', :auth_algorithm => 'sha1',
                    :encryption_algorithm => 'aes-256', :pfs => 'group5',
                    :phase1_negotiation_mode => 'main', :lifetime => {'units' => 'seconds', 'value' => 3600},
                    :ike_version => 'v1'
                  }
      Fog::Network[:openstack].create_ike_policy(attributes).body
    end

    tests('#list_ike_policies').formats('ikepolicies' => [@ike_policy_format]) do
      Fog::Network[:openstack].list_ike_policies.body
    end

    tests('#get_ike_policy').formats('ikepolicy' => @ike_policy_format) do
      ike_policy_id = Fog::Network[:openstack].ike_policies.all.first.id
      Fog::Network[:openstack].get_ike_policy(ike_policy_id).body
    end

    tests('#update_ike_policy').formats('ikepolicy' => @ike_policy_format) do
      ike_policy_id = Fog::Network[:openstack].ike_policies.all.first.id
      attributes = {:name => 'rename-test-ike-policy', :description => 'Test VPN IKE Policy',
                    :tenant_id => 'tenant_id', :auth_algorithm => 'sha1',
                    :encryption_algorithm => 'aes-256', :pfs => 'group5',
                    :phase1_negotiation_mode => 'main', :lifetime => {'units' => 'seconds', 'value' => 3600},
                    :ike_version => 'v1'
                  }
      Fog::Network[:openstack].update_ike_policy(ike_policy_id, attributes).body
    end

    tests('#delete_ike_policy').succeeds do
      ike_policy_id = Fog::Network[:openstack].ike_policies.all.first.id
      Fog::Network[:openstack].delete_ike_policy(ike_policy_id)
    end
  end

  tests('failure') do
    tests('#get_ike_policy').raises(Fog::Network::OpenStack::NotFound) do
      Fog::Network[:openstack].get_ike_policy(0)
    end

    tests('#update_ike_policy').raises(Fog::Network::OpenStack::NotFound) do
      Fog::Network[:openstack].update_ike_policy(0, {})
    end

    tests('#delete_ike_policy').raises(Fog::Network::OpenStack::NotFound) do
      Fog::Network[:openstack].delete_ike_policy(0)
    end
  end
end
