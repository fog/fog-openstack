Shindo.tests('@inspector | Introspection rules requests', ['openstack']) do
  @inspector = Fog::Introspection::OpenStack.new
  @rules_id = Fog::UUID.uuid
  @rules = {
    'description' => Fog::Nullable::String,
    'actions'     => Array,
    'conditions'  => Array,
    'uuid'        => Fog::Nullable::String,
  }

  tests('success') do
    tests('#list_rules').data_matches_schema('rules' => @rules) do
      @inspector.list_rules.body
    end

    tests('#create_rules').data_matches_schema('rules' => @rules) do
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
      @inspector.create_rules(attributes).body
    end

    tests('#get_rules').data_matches_schema('rules' => @rules) do
      @inspector.get_rules(@rules_id).body
    end

    tests('#delete_rules').succeeds do
      @inspector.delete_rules(@rules_id)
    end

    tests('#delete_rules_all').succeeds do
      @inspector.delete_rules_all
    end
  end
end
