require "test_helper"
require "helpers/dns_v2_helper"

describe "Fog::OpenStack::DNS::V2 | zone requests" do
  before do
    @dns, @zone, @zone_id = set_dns_data

    @zone_format = {
      "id"             => String,
      "pool_id"        => String,
      "project_id"     => String,
      "name"           => String,
      "email"          => String,
      "ttl"            => Integer,
      "serial"         => Integer,
      "status"         => String,
      "action"         => String,
      "description"    => String,
      "masters"        => Array,
      "type"           => String,
      "transferred_at" => String,
      "version"        => Integer,
      "created_at"     => String,
      "updated_at"     => String,
      "links"          => Hash
    }
  end

  describe "success" do
    it "#list_zones" do
      @dns.list_zones.body.must_match_schema("zones" => [@zone_format])
    end

    it "#create_zone" do
      @zone.body.must_match_schema(@zone_format)
    end

    it "#get_zone" do
      @dns.get_zone(@zone_id).body.must_match_schema(@zone_format)
    end

    it "#update_zone" do
      @dns.update_zone(@zone_id, "email" => 'new_hostmaster@example.org').body.must_match_schema(@zone_format)
    end

    it "#delete_zone" do
      @dns.delete_zone(@zone_id).body.must_match_schema(@zone_format)
    end
  end
end
