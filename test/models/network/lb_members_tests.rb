require "test_helper"

describe "Fog::Network[:openstack] | lb_members" do
  before do
    @lb_member = Fog::Network[:openstack].lb_members.create(
      :pool_id => 'pool_id',
      :address => '10.0.0.1',
      :protocol_port => 80,
      :weight => 100
    )

    @lb_members = Fog::Network[:openstack].lb_members
  end

  describe "success" do
    it "#all" do
      @lb_members.all[0].status.must_equal "ACTIVE"
    end

    it "#get" do
      @lb_members.get(@lb_member.id).status.must_equal "ACTIVE"
    end

  end

  after do
    @lb_member.destroy
  end
end
