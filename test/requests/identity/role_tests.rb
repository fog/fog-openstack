require "test_helper"

describe "Fog::Identity[:openstack] | role requests" do
  before do
    @identity = Fog::OpenStack::Identity.new(:openstack_identity_api_version => 'v2.0')

    @role_format = {
      'id'   => String,
      'name' => String
    }

    @user   = @identity.list_users.body['users'].first
    @tenant = @identity.list_tenants.body['tenants'].first
    @role   = @identity.create_role("Role Name").body['role']
  end

  describe "success" do
    it "#create_role('Role Name')" do
      @role.must_match_schema(@role_format, nil, :allow_optional_rules => false)
    end

    it "#list_roles" do
      @identity.list_roles.body.must_match_schema('roles' => [@role_format])
    end

    it "#get_role" do
      @identity.get_role(@role['id']).body['role'].must_match_schema(@role_format)
    end

    it "#create_user_role(@tenant['id'], @user['id'], @role['id'])" do
      @identity.create_user_role(@tenant['id'], @user['id'], @role['id']).body['role'].
        must_match_schema(@role_format)
    end

    it "#list_roles_for_user_on_tenant" do
      @identity.list_roles_for_user_on_tenant(@tenant['id'], @user['id']).body['roles'].
        must_match_schema([@role_format])
    end

    it "#delete_user_role with tenant" do
      @identity.delete_user_role(@tenant['id'], @user['id'], @role['id']).body.
        must_equal ""
    end

    it "#delete_user_role with tenant" do
      @identity.delete_user_role(@tenant['id'], @user['id'], @role['id']).status.
        must_equal 204
    end

    it "#delete_role" do
      @identity.delete_role(@role['id']).status.must_equal 204
    end
  end
end
