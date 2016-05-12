Shindo.tests("Fog::Identity[:openstack] | roles", ['openstack']) do
  @identity = Fog::Identity::OpenStack.new(:openstack_auth_url => 'http://openstack:35357/v2.0/tokens')
  @tenant   = @identity.tenants.create(:name => 'test_user')
  @user     = @identity.users.create(:name => 'test_user', :tenant_id => @tenant.id, :password => 'spoof')
  @role     = @identity.roles(:user => @user, :tenant => @tenant).create(:name => 'test_role')
  @roles    = @identity.roles(:user => @user, :tenant => @tenant)

  tests('success') do
    tests('#all').succeeds do
      @roles.all
    end

    tests('#get').succeeds do
      @roles.get @roles.first.id
    end
  end

  @role.destroy
  @user.destroy
  @tenant.destroy
end
