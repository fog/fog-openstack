require "test_helper"

describe "Shindo.tests('@compute | security group requests" do
  before do
    @security_group = Hash.new
    @security_group_rule = Hash.new
    @security_group_format = {
      "id"          => Integer,
      "rules"       => Array,
      "tenant_id"   => String,
      "name"        => String,
      "description" => String
    }

    @security_group_rule_format = {
      "id"              => Integer,
      "from_port"       => Integer,
      "to_port"         => Integer,
      "ip_protocol"     => String,
      "group"           => Hash,
      "ip_range"        => Hash,
      "parent_group_id" => Integer
    }

    @compute = Fog::OpenStack::Compute.new
    @security_group = @compute.create_security_group('from_shindo_test',
                                                     'this is from the shindo test'
    ).body
    @security_group_id = @security_group['security_group']['id']

    @security_group_rule = @compute.create_security_group_rule(@security_group_id,
                                                               "tcp",
                                                               2222,
                                                               3333,
                                                               "20.20.20.20/24"
                                                              ).body
    @security_group_rule_id = @security_group_rule['security_group_rule']['id']
  end

  describe "success" do
    it "#create_security_group(name, description)" do
      @security_group.must_match_schema("security_group" => @security_group_format)
    end

    it "#create_security_group_rule(parent_group_id, ip_protocol, from_port, to_port, cidr, group_id=nil)" do
      @security_group_rule.must_match_schema("security_group_rule" => @security_group_rule_format)
    end

    it "#list_security_groups" do
      @compute.list_security_groups.body.
        must_match_schema("security_groups" => [@security_group_format])
    end

    it "#get_security_group(security_group_id)" do
      @compute.get_security_group(@security_group_id).body.
        must_match_schema("security_group" => @security_group_format)
    end

    it "#get_security_group_rule" do
      @compute.create_security_group_rule(@security_group_id, "tcp", 2222, 3333, "20.20.20.20/24").body
      @compute.get_security_group_rule(@security_group_rule_id).body.
        must_match_schema("security_group_rule" => @security_group_rule_format)
    end

    it "#delete_security_group_rule(security_group_rule_id" do
      @compute.delete_security_group_rule(@security_group_rule_id).status.must_equal 202
    end

    it "#delete_security_group(security_group_id" do
      @compute.delete_security_group(@security_group_id)

      groups = @compute.list_security_groups.body['security_groups']
      groups.any? do |group|
        group['id'] == @security_group_id
      end.must_equal false
    end
  end
end
