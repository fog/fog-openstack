require "test_helper"
require "helpers/network_helper"
require "helpers/model_helper"

describe "Fog::OpenStack::Network | security_group model" do
  model_tests(network.security_groups, :name => "fogsecgroup")

  describe "success" do
    before do
      attributes = {:name => "my_secgroup", :description => "my sec group desc"}
      @secgroup = network.security_groups.create(attributes)
      @secgroup.wait_for { ready? } unless Fog.mocking?
    end

    it "#create" do
      @secgroup.id.wont_be_nil
    end

    it "#update" do
      @secgroup.name = 'new_sg_name'
      @secgroup.name.must_equal 'new_sg_name'
    end

    it "#destroy" do
      @secgroup.destroy.must_equal true
    end
  end
end
