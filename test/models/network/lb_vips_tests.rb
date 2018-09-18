require "test_helper"
require "helpers/network_helper"

describe "Fog::OpenStack::Network | lb_vips" do
  before do
    @lb_vip = network.lb_vips.create(
      :subnet_id     => 'subnet_id',
      :pool_id       => 'pool_id',
      :protocol      => 'HTTP',
      :protocol_port => 80
    )
    @lb_vips = network.lb_vips
  end

  after do
    @lb_vip.destroy
  end

  describe "success" do
    it "#all" do
      @lb_vips.all[0].status.must_equal "ACTIVE"
    end

    it "#get" do
      @lb_vips.get(@lb_vip.id).status.must_equal "ACTIVE"
    end
  end
end
