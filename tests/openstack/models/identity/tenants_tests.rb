Shindo.tests("Fog::Compute[:openstack] | tenants", ['openstack']) do
  openstack = Fog::Identity::OpenStack.new(:openstack_auth_url => 'http://openstack:35357/v2.0/tokens')
  @instance = openstack.tenants.create(:name => 'test')

  tests('success') do
    tests('#find_by_id').succeeds do
      openstack = Fog::Identity::OpenStack.new(:openstack_auth_url => 'http://openstack:35357/v2.0/tokens')
      tenant = openstack.tenants.find_by_id(@instance.id)
      tenant.id == @instance.id
    end

    tests('#destroy').succeeds do
      openstack = Fog::Identity::OpenStack.new(:openstack_auth_url => 'http://openstack:35357/v2.0/tokens')
      openstack.tenants.destroy(@instance.id)
    end
  end

  tests('fails') do
    pending if Fog.mocking?

    tests('#find_by_id').raises(Fog::Identity::OpenStack::NotFound) do
      openstack = Fog::Identity::OpenStack.new(:openstack_auth_url => 'http://openstack:35357/v2.0/tokens')
      openstack.tenants.find_by_id('fake')
    end

    tests('#destroy').raises(Fog::Identity::OpenStack::NotFound) do
      openstack = Fog::Identity::OpenStack.new(:openstack_auth_url => 'http://openstack:35357/v2.0/tokens')
      openstack.tenants.destroy('fake')
    end
  end
end
