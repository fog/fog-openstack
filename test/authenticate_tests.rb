require 'test_helper'

describe "OpenStack authentication" do
  before do
    @old_mock_value = Excon.defaults[:mock]
    Excon.defaults[:mock] = true
    Excon.stubs.clear

    @expires      = Time.now.utc + 600
    @token        = Fog::Mock.random_numbers(8).to_s
    @tenant_token = Fog::Mock.random_numbers(8).to_s

    @body = {
      "access" => {
        "token"          => {
          "expires" => @expires.iso8601,
          "id"      => @token,
          "tenant"  => {
            "enabled"     => true,
            "description" => nil,
            "name"        => "admin",
            "id"          => @tenant_token,
          }
        },
        "serviceCatalog" => [
          {
            "endpoints"       => [
              {
                "adminURL"    => "http://example:8774/v2/#{@tenant_token}",
                "region"      => "RegionOne",
                "internalURL" => "http://example:8774/v2/#{@tenant_token}",
                "id"          => Fog::Mock.random_numbers(8).to_s,
                "publicURL"   => "http://example:8774/v2/#{@tenant_token}"
              }
            ],
            "endpoints_links" => [],
            "type"            => "compute",
            "name"            => "nova"
          },
          {
            "endpoints"       => [
              {
                "adminURL"    => "http://example:9292",
                "region"      => "RegionOne",
                "internalURL" => "http://example:9292",
                "id"          => Fog::Mock.random_numbers(8).to_s,
                "publicURL"   => "http://example:9292"
              }
            ],
            "endpoints_links" => [],
            "type"            => "image",
            "name"            => "glance"
          }
        ],
        "user"           => {
          "username"    => "admin",
          "roles_links" => [],
          "id"          => Fog::Mock.random_numbers(8).to_s,
          "roles"       => [
            {"name" => "admin"},
            {"name" => "KeystoneAdmin"},
            {"name" => "KeystoneServiceAdmin"}
          ],
          "name"        => "admin"
        },
        "metadata"       => {
          "is_admin" => 0,
          "roles"    => [
            Fog::Mock.random_numbers(8).to_s,
            Fog::Mock.random_numbers(8).to_s,
            Fog::Mock.random_numbers(8).to_s
          ]
        }
      }
    }
  end

  it "with v2" do
    Excon.stub(
      {:method => 'POST', :path => "/v2.0/tokens"},
      {:status => 200, :body => Fog::JSON.encode(@body)}
    )

    expected = {
      :user                  => @body['access']['user'],
      :tenant                => @body['access']['token']['tenant'],
      :server_management_url => @body['access']['serviceCatalog'].
                                     first['endpoints'].first['publicURL'],
      :token                 => @token,
      :expires               => @expires.iso8601,
      :current_user_id       => @body['access']['user']['id'],
      :unscoped_token        => @token
    }

    assert(expected) do
      Fog::OpenStack.authenticate_v2(
        :openstack_auth_uri     => URI('http://example'),
        :openstack_tenant       => 'admin',
        :openstack_service_type => %w[compute])
    end
  end

  it "validates token" do
    creds = {
      :openstack_auth_url => 'http://openstack:35357',
      :openstack_identity_api_version => 'v2.0'
    }
    identity = Fog::OpenStack::Identity.new(creds)
    identity.validate_token(@token, @tenant_token)
    identity.validate_token(@token)
  end

  it "checks token" do
    creds = {
      :openstack_auth_url => 'http://openstack:35357',
      :openstack_identity_api_version => 'v2.0'
    }
    identity = Fog::OpenStack::Identity.new(creds)
    identity.check_token(@token, @tenant_token)
    identity.check_token(@token)
  end

  it "v2 missing service" do
    Excon.stub(
      {:method => 'POST', :path => "/v2.0/tokens"},
      {:status => 200, :body => Fog::JSON.encode(@body)})

    service = Object.new
    service.extend(Fog::OpenStack::Core)
    service.send(
      :setup,
      :openstack_auth_url     => 'http://example',
      :openstack_tenant       => 'admin',
      :openstack_service_type => %w[network],
      :openstack_api_key      => 'secret',
      :openstack_username     => 'user')
    proc do
      service.send(:authenticate)
    end.must_raise Fog::OpenStack::Auth::Catalog::ServiceTypeError
  end

  it "v2 missing storage service" do
    Excon.stub(
      {:method => 'POST', :path => "/v2.0/tokens"},
      {:status => 200, :body => Fog::JSON.encode(@body)}
    )

    service = Object.new
    service.extend(Fog::OpenStack::Core)
    service.send(
      :setup,
      :openstack_auth_url     => 'http://example',
      :openstack_tenant       => 'admin',
      :openstack_api_key      => 'secret',
      :openstack_username     => 'user',
      :openstack_service_type => 'object-store')

    proc do
      service.send(:authenticate)
    end.must_raise Fog::OpenStack::Auth::Catalog::ServiceTypeError
  end

  it "v2 auth with two compute services" do
    body_clone = @body.clone
    body_clone["access"]["serviceCatalog"] <<
      {
        "endpoints"       => [
          {
            "adminURL"    => "http://example2:8774/v2/#{@tenant_token}",
            "region"      => "RegionOne",
            "internalURL" => "http://example2:8774/v2/#{@tenant_token}",
            "id"          => Fog::Mock.random_numbers(8).to_s,
            "publicURL"   => "http://example2:8774/v2/#{@tenant_token}"
          }
        ],
        "endpoints_links" => [],
        "type"            => "compute",
        "name"            => "nova2"
      }

    Excon.stub(
      {:method => 'POST', :path => "/v2.0/tokens"},
      {:status => 200, :body => Fog::JSON.encode(body_clone)})

    service = Object.new
    service.extend(Fog::OpenStack::Core)
    service.send(
      :setup,
      :openstack_auth_url     => 'http://example',
      :openstack_tenant       => 'admin',
      :openstack_api_key      => 'secret',
      :openstack_username     => 'user',
      :openstack_service_type => 'compute')

    proc do
      service.send(:authenticate)
    end.must_raise Fog::OpenStack::Auth::Catalog::EndpointError, 'Multiple endpoints found'
  end

  after do
    Excon.stubs.clear
    Excon.defaults[:mock] = @old_mock_value
  end
end
