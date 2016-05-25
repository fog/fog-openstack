require "test_helper"

describe "Fog::Network[:openstack] | routers" do
  before do
    @router = Fog::Network[:openstack].routers.create(
      :name           => 'router_name',
      :admin_state_up => true
    )

    @routers = Fog::Network[:openstack].routers
  end

  describe "success" do
    it "#all" do
      @routers.all[0].status.must_equal "ACTIVE"
    end

    it "#get" do
      @routers.get(@router.id).status.must_equal "ACTIVE"
    end
  end

  after do
    @router.destroy
  end
end
