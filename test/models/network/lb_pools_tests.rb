require "test_helper"

describe "Fog::Network[:openstack] | lb_pools" do
  before do
    @lb_pool = Fog::Network[:openstack].lb_pools.create(
      :subnet_id => 'subnet_id',
      :protocol  => 'HTTP',
      :lb_method => 'ROUND_ROBIN'
    )

    @lb_pools = Fog::Network[:openstack].lb_pools
  end

  describe "success" do
    it "#all" do
      @lb_pools.all[0].status.must_equal "ACTIVE"
    end

    it "#get" do
      @lb_pools.get(@lb_pool.id).status.must_equal "ACTIVE"
    end
  end

  after do
    @lb_pool.destroy
  end
end
