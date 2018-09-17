require "test_helper"

describe "Fog::OpenStack::Compute | security_group" do
  describe "success" do
    let(:fog) { Fog::OpenStack::Compute.new }
    let(:security_group) do
      fog.security_groups.create(
        :name        => 'my_group',
        :description => 'my group'
      )
    end

    after do
      security_group.destroy if security_group
    end

    describe "#create" do
      it "name" do
        security_group.name.must_equal 'my_group'
      end

      it "description" do
        security_group.description.must_equal 'my group'
      end

      it "security_group_rules" do
        security_group.security_group_rules.must_equal []
      end

      it "tenant_id" do
        security_group.tenant_id.wont_be_nil
      end
    end

    describe "#rules" do
      it "#create" do
        rules_count = security_group.security_group_rules.count
        rule = security_group.security_group_rules.create(
          :parent_group_id => security_group.id,
          :ip_protocol     => 'tcp',
          :from_port       => 1234,
          :to_port         => 1234,
          :ip_range        => {"cidr" => "0.0.0.0/0"}
        )
        security_group.security_group_rules.count.must_equal(rules_count + 1)
        security_group_rule = security_group.security_group_rules.find { |r| r.id == rule.id }
        security_group_rule.attributes.must_equal rule.attributes
      end

      it "#destroy" do
        # Sometimes the reload comes not empty!
        skip unless Minitest::Test::UNIT_TESTS_CLEAN
        rule = security_group.security_group_rules.create(
          :parent_group_id => security_group.id,
          :ip_protocol     => 'tcp',
          :from_port       => 1234,
          :to_port         => 1234,
          :ip_range        => {"cidr" => "0.0.0.0/0"}
        )
        rule.destroy
        rule.reload.must_equal nil
      end
    end
  end
end
