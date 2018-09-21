require "test_helper"
require "helpers/network_helper"

describe "Fog::OpenStack::Network | lb_members" do
  before do
    @lb_member = network.lb_members.create(
      :pool_id       => 'pool_id',
      :address       => '10.0.0.1',
      :protocol_port => 80,
      :weight        => 100
    )
    @lb_members = network.lb_members
  end

  after do
    @lb_member.destroy
  end

  describe "success" do
    it "#all" do
      @lb_members.all[0].status.must_equal "ACTIVE"
    end

    it "#get" do
      @lb_members.get(@lb_member.id).status.must_equal "ACTIVE"
    end
  end
end
