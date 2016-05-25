require "test_helper"

require "helpers/model_helper"

describe "Fog::Network[:openstack] | security_group model" do
  model_tests(Fog::Network[:openstack].security_groups, {:name => "fogsecgroup"})

  describe "success" do
    before do
      attributes = {:name => "my_secgroup", :description => "my sec group desc"}
      @secgroup = Fog::Network[:openstack].security_groups.create(attributes)
      @secgroup.wait_for { ready? } unless Fog.mocking?
    end

    it "#create" do
      @secgroup.id.wont_be_nil
    end

    it "#destroy" do
      @secgroup.destroy.must_equal true
    end
  end
end
