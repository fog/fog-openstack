require "test_helper"

describe "Fog::OpenStack::Compute | tenant requests" do
  before do
    @tenant_format = {
      'id'          => String,
      'name'        => String,
      'enabled'     => Fog::Boolean,
      'description' => Fog::Nullable::String
    }
  end

  describe "success" do
    it "#list_tenants" do
      identity = Fog::OpenStack::Identity.new(:openstack_identity_api_version => 'v2.0')
      identity.list_tenants.body.
        must_match_schema('tenants_links' => Array, 'tenants' => [@tenant_format])
    end

    it "#set_tenant admin" do
      Fog::OpenStack::Compute.new.set_tenant("admin").must_equal true
    end
  end
end
