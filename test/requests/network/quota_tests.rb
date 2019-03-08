require 'test_helper'

describe "Fog::OpenStack::Network | quota requests" do
  before do
    identity = Fog::OpenStack::Identity.new(:openstack_identity_api_version => 'v2.0')
    @tenant_id = identity.list_tenants.body['tenants'].first['id']
    @quota_format = {
      'subnet'     => Fog::Nullable::Integer,
      'router'     => Fog::Nullable::Integer,
      'port'       => Fog::Nullable::Integer,
      'network'    => Fog::Nullable::Integer,
      'floatingip' => Fog::Nullable::Integer
    }

    @quotas_format = [
      {
        'subnet'     => Fog::Nullable::Integer,
        'router'     => Fog::Nullable::Integer,
        'port'       => Fog::Nullable::Integer,
        'network'    => Fog::Nullable::Integer,
        'floatingip' => Fog::Nullable::Integer,
        'tenant_id'  => Fog::Nullable::String
      }
    ]

    @quota = network.get_quota(@tenant_id).body['quota']
  end

  describe "success" do
    it "#get_quotas" do
      network.get_quotas.body.must_match_schema('quotas' => @quotas_format)
    end

    it "#get_quota" do
      @quota.must_match_schema(@quota_format)
    end

    it "#update_quota" do
      new_values = @quota.merge(
        'volumes'   => @quota['subnet'] / 2,
        'snapshots' => @quota['router'] / 2
      )

      network.update_quota(@tenant_id, new_values.clone)
      network.get_quota(@tenant_id).body['quota'].must_equal new_values
      network.update_quota(@tenant_id, @quota.clone)
      network.get_quota(@tenant_id).body['quota'].must_equal @quota
    end
  end

  describe "#delete_quota" do
    it "succeeds" do
      network.delete_quota(@tenant_id).status.must_equal 204
    end
  end
end
