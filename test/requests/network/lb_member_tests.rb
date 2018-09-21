require 'test_helper'

describe "Fog::OpenStack::Network | lb_member requests" do
  describe "success" do
    before do
      @lb_member_format = {
        'id'             => String,
        'pool_id'        => String,
        'address'        => String,
        'protocol_port'  => Integer,
        'weight'         => Integer,
        'status'         => String,
        'admin_state_up' => Fog::Boolean,
        'tenant_id'      => String
      }

      pool_id = "pool_id"
      address = "10.0.0.1"
      protocol_port = 80
      weight = 100
      attributes = {
        :admin_state_up => true,
        :tenant_id      => 'tenant_id'
      }
      @lb_member = network.create_lb_member(pool_id, address, protocol_port,
        weight, attributes).body
      @lb_member_id = @lb_member["member"]["id"]
    end

    it "#create_lb_member" do
      @lb_member.must_match_schema('member' => @lb_member_format)
    end

    it "#list_lb_members" do
      network.list_lb_members.body.must_match_schema('members' => [@lb_member_format])
    end

    it "#get_lb_member" do
      lb_member_id = network.lb_members.all.first.id
      network.get_lb_member(lb_member_id).body.
        must_match_schema('member' => @lb_member_format)
    end

    it "#update_lb_member" do
      lb_member_id = network.lb_members.all.first.id
      attributes = {
        :pool_id        => "new_pool_id",
        :weight         => 50,
        :admin_state_up => false
      }

      network.update_lb_member(lb_member_id, attributes).body.
        must_match_schema('member' => @lb_member_format)
    end

    it "#delete_lb_member" do
      lb_member_id = network.lb_members.all.first.id
      network.delete_lb_member(lb_member_id).status.must_equal 204
    end
  end

  describe "failure" do
    it "#get_lb_member" do
      proc do
        network.get_lb_member(0)
      end.must_raise Fog::OpenStack::Network::NotFound
    end

    it "#update_lb_member" do
      proc do
        network.update_lb_member(0, {})
      end.must_raise Fog::OpenStack::Network::NotFound
    end

    it "#delete_lb_member" do
      proc do
        network.delete_lb_member(0)
      end.must_raise Fog::OpenStack::Network::NotFound
    end
  end
end
