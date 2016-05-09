Shindo.tests('Fog::Identity[:openstack] | role requests', ['openstack']) do
  @role_format = {
    'id'   => String,
    'name' => String
  }

  @identity = Fog::Identity::OpenStack.new(:openstack_auth_url => 'http://openstack:35357/v2.0/tokens')

  @user   = @identity.list_users.body['users'].first
  @tenant = @identity.list_tenants.body['tenants'].first
  tests('success') do

    tests('#create_role("Role Name")').formats(@role_format, false) do
      @role = @identity.create_role("Role Name").body['role']
    end

    tests('#list_roles').formats({'roles' => [@role_format]}) do
      @identity.list_roles.body
    end

    tests("#get_role('#{@role['id']}')").formats(@role_format) do
      @identity.get_role(@role['id']).body['role']
    end

    tests('#create_user_role(@tenant["id"], @user["id"], @role["id"])').formats(@role_format) do
      @identity.create_user_role(@tenant['id'], @user['id'], @role['id']).body['role']
    end

    tests("#list_roles_for_user_on_tenant('#{@tenant['id']}','#{@user['id']}')").formats([@role_format]) do
      @identity.list_roles_for_user_on_tenant(@tenant['id'], @user['id']).body['roles']
    end

    tests("#delete_user_role with tenant").returns("") do
      @identity.delete_user_role(@tenant['id'], @user['id'], @role['id']).body
    end

    tests("#delete_user_role with tenant").formats(@role_format) do
      # FIXME - Response (under mocks) is empty String which does not match schema
      pending
      @identity.delete_user_role(@tenant['id'], @user['id'], @role['id']).body
    end

    tests("#delete_role('#{@role['id']}')").succeeds do
      @identity.delete_role(@role['id']).body
    end

  end
end
