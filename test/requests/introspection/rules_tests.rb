require "test_helper"

describe "@inspector | Introspection rules requests" do
  before do
    @inspector = Fog::OpenStack::Introspection.new
    @rules_id = Fog::UUID.uuid
    @rules = {
      'description' => Fog::Nullable::String,
      'actions'     => Array,
      'conditions'  => Array,
      'uuid'        => Fog::Nullable::String,
    }
  end

  describe "success" do
    it "#list_rules" do
      @inspector.list_rules.body.must_match_schema('rules' => @rules)
    end

    it "#create_rules" do
      attributes = {
        "actions"     => {
          "action" => "set-attribute",
          "path"   => "/driver_info/ipmi_address",
          "value"  => "{data[inventory][bmc_address]}"
        },
        "conditions"  => {
          "field" => "node://property.path",
          "op"    => "eq",
          "value" => "val",
        },
        "description" => "",
        "uuid"        => ""
      }
      @inspector.create_rules(attributes).body.must_match_schema('rules' => @rules)
    end

    it "#get_rules" do
      @inspector.get_rules(@rules_id).body.must_match_schema('rules' => @rules)
    end

    it "#delete_rules" do
      @inspector.delete_rules(@rules_id).status.must_equal 204
    end

    it "#delete_rules_all" do
      @inspector.delete_rules_all.status.must_equal 204
    end
  end
end
