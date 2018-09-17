require "test_helper"

describe "Fog::OpenStack::Planning | plan" do
  describe "success" do
    before do
      @instance = Fog::OpenStack::Planning.new.roles.first
      @plan = Fog::OpenStack::Planning.new.list_plans.body.first
    end

    it "#add_role" do
      @instance.add_to_plan(@plan['uuid']).status.must_equal 201
    end

    it "#remove_role" do
      @instance.remove_from_plan(@plan['uuid']).status.must_equal 200
    end
  end
end
