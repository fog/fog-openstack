require "test_helper"

describe "Fog::Openstack[:planning] | plans" do
  describe "success" do
    before do
      @planning = Fog::Openstack[:planning]
      @instance = @planning.plans.all.first
    end

    it "#all" do
      @instance.uuid.wont_be_empty
    end

    it "#get" do
      @planning.plans.get(@instance.uuid).uuid.must_equal @instance.uuid
    end

    it "#find_by_*" do
      plan = @planning.plans.find_by_name(@instance.name)
      plan.name.must_equal @instance.name
    end
  end
end
