require "test_helper"

describe "Fog::Compute[:openstack] | quota requests" do
  before do
    @tenant_id = Fog::Compute[:openstack].list_tenants.body['tenants'].first['id']
    @quota_set_format = {
      'key_pairs'                   => Fixnum,
      'metadata_items'              => Fixnum,
      'injected_file_content_bytes' => Fixnum,
      'injected_file_path_bytes'    => Fixnum,
      'injected_files'              => Fixnum,
      'ram'                         => Fixnum,
      'floating_ips'                => Fixnum,
      'instances'                   => Fixnum,
      'cores'                       => Fixnum,
      'security_groups'             => Fog::Nullable::Integer,
      'security_group_rules'        => Fog::Nullable::Integer,
      'volumes'                     => Fog::Nullable::Integer,
      'gigabytes'                   => Fog::Nullable::Integer,
      'id'                          => String
    }

    @compute = Fog::Compute[:openstack]
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
