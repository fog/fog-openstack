Shindo.tests("Fog::Identity[:openstack] | tenant", ['openstack']) do
  tests('success') do
    @openstack = Fog::Identity::OpenStack.new(:openstack_auth_url => 'http://openstack:35357/v2.0/tokens')

    tests('#roles_for(0)').succeeds do
      instance = @openstack.tenants.first
      instance.roles_for(0)
    end

    tests('#users').succeeds do
      instance = @openstack.tenants.first
      openstack = Fog::Identity::OpenStack.new(:openstack_auth_url => 'http://openstack:35357/v2.0/tokens')

      instance.users.count != openstack.users.count
    end
  end

  tests('CRUD') do
    tests('#create').succeeds do
      @instance = @openstack.tenants.create(:name => 'test')
      !@instance.id.nil?
    end

    tests('#update').succeeds do
      @instance.update(:name => 'test2')
      @instance.name == 'test2'
    end

    tests('#destroy').succeeds do
      @instance.destroy == true
    end
  end
end
