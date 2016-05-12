Shindo.tests("Fog::Identity[:openstack] | role", ['openstack']) do
  @identity = Fog::Identity::OpenStack.new(:openstack_auth_url => 'http://openstack:35357/v2.0/tokens')
  @instance = @identity.roles.new(
    :name    => 'Role Name',
    :user_id => 1,
    :role_id => 1
  )
  @tenant   = @identity.tenants.create(:name => 'test_user')
  @user     = @identity.users.create(:name => 'test_user', :tenant_id => @tenant.id, :password => 'spoof')

  tests('success') do
    tests('#save').returns(true) do
      @instance.save
    end

    tests('#add_to_user(@user.id, @tenant.id)').returns(true) do
      @instance.add_to_user(@user.id, @tenant.id)
    end

    tests('#remove_to_user(@user.id, @tenant.id)').returns(true) do
      @instance.remove_to_user(@user.id, @tenant.id)
    end

    tests('#destroy').returns(true) do
      @instance.destroy
    end
  end

  @user.destroy
  @tenant.destroy
end
