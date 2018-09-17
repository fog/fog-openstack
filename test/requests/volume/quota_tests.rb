require 'test_helper'

describe "Fog::OpenStack::Volume | quota requests" do
  before do
    @volume = Fog::OpenStack::Volume.new
    identity = Fog::OpenStack::Identity.new(:openstack_identity_api_version => 'v2.0')
    @tenant_id = identity.list_tenants.body['tenants'].first['id']
    @quota_set_format = {
      'volumes'   => Fog::Nullable::Integer,
      'gigabytes' => Fog::Nullable::Integer,
      'snapshots' => Fog::Nullable::Integer,
      'id'        => String
    }
    @quota = @volume.get_quota(@tenant_id).body['quota_set']
  end

  describe "success" do
    it "#get_quota_defaults" do
      @volume.get_quota_defaults(@tenant_id).body.
        must_match_schema('quota_set' => @quota_set_format)
    end

    it "#get_quota" do
      @quota.must_match_schema(@quota_set_format)
    end

    it "updates quota" do
      @new_values = @quota.merge(
        'volumes'   => @quota['volumes'] / 2,
        'snapshots' => @quota['snapshots'] / 2
      )

      @volume.update_quota(@tenant_id, @new_values.clone)
      @volume.get_quota(@tenant_id).body['quota_set'].must_match_schema @new_values
    end
  end
end
