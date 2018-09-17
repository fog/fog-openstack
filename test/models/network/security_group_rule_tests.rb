require "test_helper"
require "helpers/network_helper"
require "helpers/model_helper"

describe "Fog::OpenStack::Network | security_group_rule model" do
  @secgroup = network.security_groups.create(:name => "fogsecgroup")
  attributes = {:security_group_id => @secgroup.id, :direction => "ingress"}
  model_tests(network.security_group_rules, attributes)

  describe "success" do
    before do
      @secgroup = network.security_groups.create(:name => "fogsecgroup")
      attributes = {
        :security_group_id => @secgroup.id,
        :direction         => "ingress",
        :protocol          => "tcp",
        :port_range_min    => 22,
        :port_range_max    => 22,
        :remote_ip_prefix  => "0.0.0.0/0"
      }
      @secgrouprule = network.security_group_rules.create(attributes)
      @secgrouprule.wait_for { ready? } unless Fog.mocking?
    end

    after do
      @secgroup.destroy
    end

    it "#create" do
      @secgrouprule.id.wont_be_nil
    end

    it "#destroy" do
      @secgrouprule.destroy.must_equal true
    end
  end
end
