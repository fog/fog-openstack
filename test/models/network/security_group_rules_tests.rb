require "test_helper"

require "helpers/collection_helper"

describe "Fog::Network[:openstack] | security_group_rules collection" do
  @secgroup   = Fog::Network[:openstack].security_groups.create({:name => "my_secgroup"})
  attributes  = {:security_group_id => @secgroup.id, :direction => "ingress"}
  collection_tests(Fog::Network[:openstack].security_group_rules, attributes)

  describe "success" do
    before do
      @secgroup   = Fog::Network[:openstack].security_groups.create({:name => "my_secgroup"})

      @attributes = {
        :security_group_id  => @secgroup.id,
        :direction          => "ingress",
        :protocol           => "tcp",
        :port_range_min     => 22,
        :port_range_max     => 22,
        :remote_ip_prefix   => "0.0.0.0/0"
      }

      @secgrouprule = Fog::Network[:openstack].security_group_rules.create(@attributes)
    end

    it "#all(filter)" do
      secgrouprule = Fog::Network[:openstack].security_group_rules.all({:direction => "ingress"})
      secgrouprule.first.direction.must_equal "ingress"
      @secgrouprule.destroy
    end
  end

  after do
    @secgroup.destroy
  end
end
