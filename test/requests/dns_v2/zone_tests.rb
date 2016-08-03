require "test_helper"

describe "Fog::DNS::OpenStack::V2 | domain requests" do
  before do
    @dns = Fog::DNS::OpenStack::V2.new

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
  end
end
