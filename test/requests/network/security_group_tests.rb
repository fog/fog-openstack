require 'test_helper'
require 'helpers/network_helper'

describe "Fog::OpenStack::Network | security_group requests" do
  before do
    @security_group_format = {
      "id"                   => String,
      "name"                 => String,
      "description"          => String,
      "tenant_id"            => String,
      "security_group_rules" => [Hash]
    }
  end

  describe "success" do
    before do
      @sec_group_id   = nil
      attributes      = {:name => "fog_security_group", :description => "tests group"}
      @security_group = network.create_security_group(attributes).body["security_group"]
      @sec_group_id   = @security_group["id"]
    end

    it "#create_security_group('fog_security_group', 'tests group')" do
      @security_group.must_match_schema(@security_group_format)
    end

    it "#get_security_group('#{@sec_group_id}')" do
      network.get_security_group(@sec_group_id).body["security_group"].
        must_match_schema(@security_group_format)
    end

    it "#list_security_groups" do
      network.list_security_groups.body.
        must_match_schema('security_groups' => [@security_group_format])
    end

    it "#update_security_group" do
      security_group_id = network.security_groups.all.first.id
      attributes = {
        :name        => "new_security_group_name",
        :description => "New sg desc",
      }
      updated = network.update_security_group(security_group_id, attributes)
      updated.body.must_match_schema("security_group" => @security_group_format)
      updated.body["security_group"]["name"].must_equal "new_security_group_name"
    end

    it "#delete_security_group('#{@sec_group_id}')" do
      network.delete_security_group(@sec_group_id).status.must_equal 204
    end
  end

  describe "failure" do
    it "#get_security_group(0)" do
      proc do
        network.get_security_group(0)
      end.must_raise Fog::OpenStack::Network::NotFound
    end

    it "#delete_security_group(0)" do
      proc do
        network.delete_security_group(0)
      end.must_raise Fog::OpenStack::Network::NotFound
    end
  end
end
