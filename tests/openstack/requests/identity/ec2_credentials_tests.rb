Shindo.tests('Fog::Identity[:openstack] | EC2 credential requests', ['openstack']) do

  @credential_format = {
    'access'    => String,
    'tenant_id' => String,
    'secret'    => String,
    'user_id'   => String,
  }

  @identity = Fog::Identity::OpenStack.new(:openstack_auth_url => "http://openstack:35357/v2.0/tokens")

  @user_id = OpenStack::Identity.get_user_id
  @tenant_id = OpenStack::Identity.get_tenant_id

  tests('success') do
    tests('#create_ec2_credential').
      formats({'credential' => @credential_format}) do
      response = @identity.create_ec2_credential(@user_id, @tenant_id)

      @ec2_credential = response.body['credential']

      response.body
    end

    tests('#get_ec2_credential').
      formats({'credential' => @credential_format}) do
      @identity.get_ec2_credential(@user_id, @ec2_credential['access']).body
    end

    tests('#list_ec2_credentials').
      formats({'credentials' => [@credential_format]}) do
      @identity.list_ec2_credentials(@user_id).body
    end

    tests('#delete_ec2_credential').succeeds do
      @identity.delete_ec2_credential(@user_id, @ec2_credential['access'])
    end

  end

end
