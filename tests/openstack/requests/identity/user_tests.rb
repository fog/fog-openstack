Shindo.tests('Fog::Identity[:openstack] | user requests', ['openstack']) do

  @user_format = {
    'id'   => String,
    'name' => String,
    'enabled'  => Fog::Boolean,
    'email'    => String,
    'tenantId' => Fog::Nullable::String
  }

  @identity = Fog::Identity[:openstack]

  tests('success') do

    @user_name = Fog::Mock.random_hex(64)
    @user_name_update = Fog::Mock.random_hex(64)

    tests("#create_user('#{@user_name}', 'mypassword', 'morph@example.com', 't3n4nt1d', true)").formats(@user_format, false) do
      @user = @identity.create_user(
        @user_name, "mypassword", "morph@example.com",
        OpenStack::Identity.get_tenant_id
      ).body['user']
    end

    tests('#list_users').formats({'users' => [@user_format]}) do
      @identity.list_users.body
    end

    tests('#get_user_by_id').formats(@user_format) do
      @identity.get_user_by_id(@user['id']).body['user']
    end

    tests('#get_user_by_name').formats(@user_format) do
      @identity.get_user_by_name(@user['name']).body['user']
    end

    tests("#update_user(#{@user['id']}, :name => 'fogupdateduser')").succeeds do
      @identity.update_user(@user['id'], :name => @user_name_update, :email => 'fog@test.com')
    end

    tests("#delete_user(#{@user['id']})").succeeds do
      @identity.delete_user(@user['id'])
    end

  end
end
