require "test_helper"

describe "Fog::OpenStack::Compute::ServerGroup" do
  describe "validate_server_group_policy" do
    it "contains only allowed policies" do
      ['affinity', 'anti-affinity', 'soft-affinity', 'soft-anti-affinity'].each do |policy|
        Fog::OpenStack::Compute::ServerGroup.validate_server_group_policy(policy).must_equal true
      end
    end

    it "raises an error" do
      assert_raises ArgumentError do
        Fog::OpenStack::Compute::ServerGroup.validate_server_group_policy('invalid-policy')
      end
    end
  end
end
