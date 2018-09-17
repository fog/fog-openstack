require 'test_helper'

describe "Fog::OpenStack::Network | security_grouprule requests" do
  before do
    @security_group_rule_format = {
      "id"                => String,
      "remote_group_id"   => Fog::Nullable::String,
      "direction"         => String,
      "remote_ip_prefix"  => Fog::Nullable::String,
      "protocol"          => Fog::Nullable::String,
      "ethertype"         => String,
      "port_range_max"    => Fog::Nullable::Integer,
      "port_range_min"    => Fog::Nullable::Integer,
      "security_group_id" => String,
      "tenant_id"         => String
    }
  end

  describe "success" do
    before do
      attributes          = {:name => "my_security_group", :description => "tests group"}
      security_group      = network.create_security_group(attributes).body["security_group"]
      @sec_group_id       = security_group["id"]
      @sec_group_rule_id  = nil

      attributes = {
        :remote_ip_prefix => "0.0.0.0/0",
        :protocol         => "tcp",
        :port_range_min   => 22,
        :port_range_max   => 22
      }
      @security_group_rule = network.create_security_group_rule(
        @sec_group_id, 'ingress', attributes
      ).body["security_group_rule"]
      @sec_group_rule_id = @security_group_rule["id"]
    end

    it "#create_security_group_rule(@sec_group_id, 'ingress', attributes)" do
      @security_group_rule.must_match_schema(@security_group_rule_format)
    end

    it "#get_security_group_rule(@sec_group_rule_id)" do
      network.get_security_group_rule(@sec_group_rule_id).
        body["security_group_rule"].must_match_schema(@security_group_rule_format)
    end

    it "#list_security_group_rules" do
      network.list_security_group_rules.body.must_match_schema(
        "security_group_rules" => [@security_group_rule_format]
      )
    end

    it "#delete_security_group_rule(@sec_group_rule_id)" do
      network.delete_security_group_rule(@sec_group_rule_id).status.must_equal 204
    end
  end

  describe "failure" do
    it "#get_security_group_rule(0)" do
      proc do
        network.get_security_group_rule(0)
      end.must_raise Fog::OpenStack::Network::NotFound
    end

    it "#delete_security_group_rule(0)" do
      proc do
        network.delete_security_group_rule(0)
      end.must_raise Fog::OpenStack::Network::NotFound
    end
  end
end
