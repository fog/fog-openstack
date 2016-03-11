Shindo.tests('Fog::Network[:openstack] | ipsec_policy requests', ['openstack']) do
  @ipsec_policy_format = {
    'id'                   => String,
    'name'                 => String,
    'description'          => String,
    'tenant_id'            => String,
    'lifetime'             => Hash,
    'pfs'                  => String,
    'transform_protocol'   => String,
    'auth_algorithm'       => String,
    'encapsulation_mode'   => String,
    'encryption_algorithm' => String
  }

  tests('success') do
    tests('#create_ipsec_policy').formats('ipsecpolicy' => @ipsec_policy_format) do
      attributes = {:name => 'test-ipsec-policy', :description => 'Test VPN ipsec Policy',
                    :tenant_id => 'tenant_id', :auth_algorithm => 'sha1',
                    :encryption_algorithm => 'aes-128', :pfs => 'group5',
                    :transform_protocol => 'esp', :lifetime => {'units' => 'seconds', 'value' => 3600},
                    :encapsulation_mode => 'tunnel'
                  }
      Fog::Network[:openstack].create_ipsec_policy(attributes).body
    end

    tests('#list_ipsec_policies').formats('ipsecpolicies' => [@ipsec_policy_format]) do
      Fog::Network[:openstack].list_ipsec_policies.body
    end

    tests('#get_ipsec_policy').formats('ipsecpolicy' => @ipsec_policy_format) do
      ipsec_policy_id = Fog::Network[:openstack].ipsec_policies.all.first.id
      Fog::Network[:openstack].get_ipsec_policy(ipsec_policy_id).body
    end

    tests('#update_ipsec_policy').formats('ipsecpolicy' => @ipsec_policy_format) do
      ipsec_policy_id = Fog::Network[:openstack].ipsec_policies.all.first.id
      attributes = {:name => 'rename-test-ipsec-policy', :description => 'Test VPN ipsec Policy',
                    :tenant_id => 'tenant_id', :auth_algorithm => 'sha1',
                    :encryption_algorithm => 'aes-128', :pfs => 'group5',
                    :transform_protocol => 'esp', :lifetime => {'units' => 'seconds', 'value' => 3600},
                    :encapsulation_mode => 'tunnel'
                  }
      Fog::Network[:openstack].update_ipsec_policy(ipsec_policy_id, attributes).body
    end

    tests('#delete_ipsec_policy').succeeds do
      ipsec_policy_id = Fog::Network[:openstack].ipsec_policies.all.first.id
      Fog::Network[:openstack].delete_ipsec_policy(ipsec_policy_id)
    end
  end

  tests('failure') do
    tests('#get_ipsec_policy').raises(Fog::Network::OpenStack::NotFound) do
      Fog::Network[:openstack].get_ipsec_policy(0)
    end

    tests('#update_ipsec_policy').raises(Fog::Network::OpenStack::NotFound) do
      Fog::Network[:openstack].update_ipsec_policy(0, {})
    end

    tests('#delete_ipsec_policy').raises(Fog::Network::OpenStack::NotFound) do
      Fog::Network[:openstack].delete_ipsec_policy(0)
    end
  end
end
