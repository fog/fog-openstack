require "test_helper"

describe "Fog::OpenStack::DNS::V1 | domain requests" do
  before do
    @dns = Fog::OpenStack::DNS::V1.new

    @domain_format = {
      "id"          => String,
      "name"        => String,
      "email"       => String,
      "ttl"         => Integer,
      "serial"      => Integer,
      "description" => String,
      "created_at"  => String,
      "updated_at"  => String
    }
  end

  describe "success" do
    it "#list_domains" do
      @dns.list_domains.body.must_match_schema("domains" => [@domain_format])
    end
  end
end
