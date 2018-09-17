require 'test_helper'

describe "Fog::Identity[:openstack] | versions" do
  before do
    @old_mock_value = Excon.defaults[:mock]
    @old_credentials = Fog.credentials
  end

  it "v2" do
    Fog.credentials = {:openstack_auth_url => 'http://openstack:35357'}

    assert(Fog::OpenStack::Identity::V2::Real) do
      Fog::Identity[:openstack].class
    end
  end

  it "v3" do
    Fog.credentials = {:openstack_auth_url => 'http://openstack:35357'}

    assert(Fog::OpenStack::Identity::V3::Real) do
      Fog::Identity[:openstack].class
    end
  end

  after do
    Excon.defaults[:mock] = @old_mock_value
    Fog.credentials = @old_credentials
  end
end
