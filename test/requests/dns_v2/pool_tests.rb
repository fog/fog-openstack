require "test_helper"
require "helpers/dns_v2_helper"

describe "Fog::OpenStack::DNS::V2 | pool requests" do
  before do
    @dns, = set_dns_data

    @pool_format = {
      "description" => String,
      "id"          => String,
      "project_id"  => String,
      "created_at"  => String,
      "attributes"  => String,
      "ns_records"  => Array,
      "links"       => Hash,
      "name"        => String,
      "updated_at"  => String
    }

    @pool_id = @dns.list_pools.body['pools'].first['id']
  end

  describe "success" do
    it "#list_pools" do
      @dns.list_pools.body.must_match_schema("pools" => [@pool_format])
    end

    it "#get_pool" do
      @dns.get_pool(@pool_id).body.must_match_schema(@pool_format)
    end
  end
end
