require "test_helper"
require "helpers/dns_v2_helper"

describe "Fog::OpenStack::DNS::V2 | recordset requests" do
  before do
    @dns, @zone, @zone_id = set_dns_data

    @recordset = @dns.create_recordset(@zone_id, 'test.example.org', 'A', ['10.0.0.1'])

    @recordset_format = {
      "description" => String,
      "links"       => Hash,
      "updated_at"  => String,
      "records"     => Array,
      "ttl"         => Integer,
      "id"          => String,
      "name"        => String,
      "project_id"  => String,
      "zone_id"     => String,
      "zone_name"   => String,
      "created_at"  => String,
      "version"     => Integer,
      "type"        => String,
      "status"      => String,
      "action"      => String
    }

    recordset_links_format = {
      "self" => String,
      "next" => String
    }

    recordset_metadata_format = {
      "total_count" => Integer
    }

    @recordset_list_format = {
      "recordsets" => [@recordset_format],
      "links"      => recordset_links_format,
      "metadata"   => recordset_metadata_format
    }
  end

  describe "success" do
    it "#list_recordsets deprecated" do
      recordset_list_body = @dns.list_recordsets(@zone_id).body
      recordset_list_body.must_match_schema(@recordset_list_format)
      recordset_list_body['recordsets'].sample['zone_id'].must_equal(@zone_id)
    end

    it "#list_recordsets" do
      recordset_list_body = @dns.list_recordsets(:zone_id => @zone_id).body
      recordset_list_body.must_match_schema(@recordset_list_format)
      recordset_list_body['recordsets'].sample['zone_id'].must_equal(@zone_id)
    end

    it "#create_recordset" do
      @recordset.body.must_match_schema(@recordset_format)
    end

    it "#get_recordset" do
      @dns.get_recordset(@zone_id, @recordset.body['id']).body.must_match_schema(@recordset_format)
    end

    it "#update_recordset" do
      @dns.update_recordset(
        @zone_id,
        @recordset.body['id'],
        "email" => 'new_hostmaster@test.example.org'
      ).body.must_match_schema(@recordset_format)
    end

    it "#delete_recordset" do
      @dns.delete_recordset(@zone_id, @recordset.body['id']).body.must_match_schema(@recordset_format)
    end
  end
end
