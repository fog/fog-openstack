require "test_helper"

require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

describe "Fog::Identity[:openstack] | EC2 credential requests" do
  before do
    @identity = Fog::OpenStack::Identity.new(:openstack_identity_api_version => 'v2.0')

    @credential_format = {
      'access'    => String,
      'tenant_id' => String,
      'secret'    => String,
      'user_id'   => String,
    }

    @user_id = OpenStack::Identity.get_user_id(@identity)
    @tenant_id = OpenStack::Identity.get_tenant_id(@identity)

    @response = @identity.create_ec2_credential(@user_id, @tenant_id)
    @ec2_credential = @response.body['credential']
  end

  describe "success" do
    it "#create_ec2_credential" do
      @response.body.must_match_schema('credential' => @credential_format)
    end

    it "#get_ec2_credential" do
      @identity.get_ec2_credential(@user_id, @ec2_credential['access']).body.
        must_match_schema('credential' => @credential_format)
    end

    it "#list_ec2_credentials" do
      @identity.list_ec2_credentials(@user_id).body.
        must_match_schema('credentials' => [@credential_format])
    end

    it "#delete_ec2_credential" do
      @identity.delete_ec2_credential(@user_id, @ec2_credential['access']).
        status.must_equal 204
    end
  end
end
