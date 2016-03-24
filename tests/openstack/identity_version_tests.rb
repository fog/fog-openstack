Shindo.tests('Fog::Identity[:openstack] | versions', ['openstack', 'identity']) do
  begin
    @old_mock_value = Excon.defaults[:mock]
    @old_credentials = Fog.credentials

    tests('v2') do
      Fog.credentials = {:openstack_auth_url => 'http://openstack:35357/v2.0/tokens'}

      returns(Fog::Identity::OpenStack::V2::Mock) do
        Fog::Identity[:openstack].class
      end
    end

    tests('v3') do
      Fog.credentials = {:openstack_auth_url => 'http://openstack:35357/v3/auth/tokens'}

      returns(Fog::Identity::OpenStack::V3::Mock) do
        Fog::Identity[:openstack].class
      end
    end
  ensure
    Excon.defaults[:mock] = @old_mock_value
    Fog.credentials = @old_credentials
  end
end
