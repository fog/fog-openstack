require "test_helper"

require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

describe "Fog::Identity[:openstack] | tenant requests" do
  before do
    @identity = Fog::OpenStack::Identity.new(:openstack_identity_api_version => 'v2.0')

    @tenant_format = {
      'id'          => String,
      'name'        => String,
      'enabled'     => Fog::Nullable::Boolean,
      'description' => Fog::Nullable::String
    }

    @role_format = {
      'id'   => String,
      'name' => String
    }

    @tenant_name = Fog::Mock.random_hex(64)
    @tenant = @identity.create_tenant('name' => @tenant_name).body
  end

  describe "success" do
    it "#list_tenants" do
      @identity.list_tenants.body.must_match_schema('tenants' => [@tenant_format], 'tenants_links' => [])
    end

    it "#list_roles_for_user_on_tenant(0,1)" do
      @identity.list_roles_for_user_on_tenant(
        @identity.current_tenant['id'], OpenStack::Identity.get_user_id(@identity)
      ).body.must_match_schema('roles' => [@role_format])
    end

    it "#create_tenant" do
      @tenant.must_match_schema('tenant' => @tenant_format)
    end

    it "#get_tenant" do
      @identity.get_tenant(@tenant['tenant']['id']).body.
        must_match_schema('tenant' => @tenant_format)
    end

    it "#update_tenant check format" do
      tenant_name_update = Fog::Mock.random_hex(64)
      tenant = @identity.update_tenant(
        @tenant['tenant']['id'],
        'name' => tenant_name_update
      )
      tenant.body.must_match_schema('tenant' => @tenant_format)
    end

    it "#update_tenant update name" do
      tenant_name_update = Fog::Mock.random_hex(64)
      tenant = @identity.update_tenant(
        @tenant['tenant']['id'], 'name' => tenant_name_update).body
      tenant['tenant']['name'].must_equal tenant_name_update
    end

    it "#delete_tenant" do
      @identity.delete_tenant(@tenant['tenant']['id'])
    end
  end
end
