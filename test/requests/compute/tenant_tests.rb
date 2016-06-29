require "test_helper"

describe "Fog::Compute[:openstack] | tenant requests" do
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
      Fog::Compute[:openstack].list_tenants.body.
        must_match_schema('tenants_links' => Array, 'tenants' => [@tenant_format])
    end

    it "#set_tenant admin" do
      Fog::Compute[:openstack].set_tenant("admin").must_equal true
    end
  end
end
