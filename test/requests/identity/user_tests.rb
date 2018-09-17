require "test_helper"

require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

describe "Fog::Identity[:openstack] | user requests" do
  before do
    @identity = Fog::OpenStack::Identity.new(:openstack_identity_api_version => 'v2.0')

    @user_format = {
      'id'       => String,
      'name'     => String,
      'enabled'  => Fog::Boolean,
      'email'    => String,
      'tenantId' => Fog::Nullable::String
    }

    @user_name = Fog::Mock.random_hex(64)
    @user_name_update = Fog::Mock.random_hex(64)

    @user = @identity.create_user(
      @user_name, "mypassword", "morph@example.com",
      OpenStack::Identity.get_tenant_id(@identity)
    ).body['user']
  end

  describe "success" do
    it "#create_user(#{@user_name}, 'mypassword', 'morph@example.com', 't3n4nt1d', true)" do
      @user.must_match_schema(@user_format, nil, :allow_optional_rules => false)
    end

    it "#list_users" do
      @identity.list_users.body["users"][0].must_match_schema(@user_format)
    end

    it "#get_user_by_id" do
      @identity.get_user_by_id(@user['id']).body['user'].must_match_schema(@user_format)
    end

    it "#get_user_by_name" do
      @identity.get_user_by_name(@user['name']).body['user'].must_match_schema(@user_format)
    end

    it "#update_user" do
      @identity.update_user(
        @user['id'], :name => @user_name_update, :email => 'fog@test.com'
      ).status.must_equal 200
    end

    it "#delete_user" do
      @identity.delete_user(@user['id']).status.must_equal 204
    end
  end
end
