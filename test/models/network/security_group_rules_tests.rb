require "test_helper"
require "helpers/network_helper"
require "helpers/collection_helper"

describe "Fog::OpenStack::Network | security_group_rules collection" do
  @secgroup   = network.security_groups.create(:name => "my_secgroup")
  attributes  = {:security_group_id => @secgroup.id, :direction => "ingress"}
  collection_tests(network.security_group_rules, attributes)

  describe "success" do
    before do
      @secgroup = network.security_groups.create(:name => "my_secgroup")

      @attributes = {
        :security_group_id => @secgroup.id,
        :direction         => "ingress",
        :protocol          => "tcp",
        :port_range_min    => 22,
        :port_range_max    => 22,
        :remote_ip_prefix  => "0.0.0.0/0"
      }

      @secgrouprule = network.security_group_rules.create(@attributes)
    end

    after do
      @secgroup.destroy
    end

    it "#all(filter)" do
      secgrouprule = network.security_group_rules.all(:direction => "ingress")
      secgrouprule.first.direction.must_equal "ingress"
      @secgrouprule.destroy
    end
  end
end
