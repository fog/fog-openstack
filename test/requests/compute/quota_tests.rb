require "test_helper"

describe "Fog::OpenStack::Compute | quota requests" do
  before do
    identity = Fog::OpenStack::Identity.new(:openstack_identity_api_version => 'v2.0')
    @tenant_id = identity.list_tenants.body['tenants'].first['id']
    @quota_set_format = {
      'key_pairs'                   => Integer,
      'metadata_items'              => Integer,
      'injected_file_content_bytes' => Integer,
      'injected_file_path_bytes'    => Integer,
      'injected_files'              => Integer,
      'ram'                         => Integer,
      'floating_ips'                => Integer,
      'instances'                   => Integer,
      'cores'                       => Integer,
      'security_groups'             => Fog::Nullable::Integer,
      'security_group_rules'        => Fog::Nullable::Integer,
      'volumes'                     => Fog::Nullable::Integer,
      'gigabytes'                   => Fog::Nullable::Integer,
      'id'                          => String
    }

    @compute = Fog::OpenStack::Compute.new
    @quota = @compute.get_quota(@tenant_id).body['quota_set']
  end

  describe "success" do
    it "#get_quota_defaults" do
      @compute.get_quota_defaults(@tenant_id).body.
        must_match_schema('quota_set' => @quota_set_format)
    end

    it "#get_quota" do
      @quota.must_match_schema(@quota_set_format)
    end

    it "#update_quota" do
      new_values = @quota.merge(
        'floating_ips' => @quota['floating_ips'] / 2,
        'cores'        => @quota['cores'] / 2
      )

      @compute.update_quota(@tenant_id, new_values.clone).status.must_equal 200
      @compute.get_quota(@tenant_id).body['quota_set'].must_equal new_values
    end
  end
end
