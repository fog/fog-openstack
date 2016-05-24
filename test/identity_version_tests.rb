require 'test_helper'

describe "Fog::Identity[:openstack] | versions" do
  before do
    @old_mock_value = Excon.defaults[:mock]
    @old_credentials = Fog.credentials
  end

  it "v2" do
    Fog.credentials = {:openstack_auth_url => 'http://openstack:35357/v2.0/tokens'}

    assert(Fog::Identity::OpenStack::V2::Mock) do
      Fog::Identity[:openstack].class
    end
  end

  it "v3" do
    Fog.credentials = {:openstack_auth_url => 'http://openstack:35357/v3/auth/tokens'}

    assert(Fog::Identity::OpenStack::V3::Mock) do
      Fog::Identity[:openstack].class
    end
  end

  after do
    Excon.defaults[:mock] = @old_mock_value
    Fog.credentials = @old_credentials
  end
end
