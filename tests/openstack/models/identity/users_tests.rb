Shindo.tests("Fog::Identity[:openstack] | users", ['openstack']) do
  openstack = Fog::Identity::OpenStack.new(:openstack_auth_url => 'http://openstack:35357/v2.0/tokens')
  tenant_id = openstack.list_tenants.body['tenants'].first['id']
  @instance = openstack.users.create(
    :name      => 'foobar',
    :email     => 'foo@bar.com',
    :tenant_id => tenant_id,
    :password  => 'spoof',
    :enabled   => true
  )

  tests('success') do
    tests('#find_by_id').succeeds do
      openstack = Fog::Identity::OpenStack.new(:openstack_auth_url => 'http://openstack:35357/v2.0/tokens')
      user = openstack.users.find_by_id(@instance.id)
      user.id == @instance.id
    end

    tests('#find_by_name').succeeds do
      openstack = Fog::Identity::OpenStack.new(:openstack_auth_url => 'http://openstack:35357/v2.0/tokens')
      user = openstack.users.find_by_name(@instance.name)
      user.name == @instance.name
    end

    tests('#destroy').succeeds do
      openstack = Fog::Identity::OpenStack.new(:openstack_auth_url => 'http://openstack:35357/v2.0/tokens')
      openstack.users.destroy(@instance.id)
    end
  end

  tests('fails') do
    pending if Fog.mocking?

    tests('#find_by_id').raises(Fog::Identity::OpenStack::NotFound) do
      Fog::Identity[:openstack].users.find_by_id('fake')
    end

    tests('#find_by_name').raises(Fog::Identity::OpenStack::NotFound) do
      Fog::Identity[:openstack].users.find_by_name('fake')
    end

    tests('#destroy').raises(Fog::Identity::OpenStack::NotFound) do
      Fog::Identity[:openstack].users.destroy('fake')
    end
  end
end
