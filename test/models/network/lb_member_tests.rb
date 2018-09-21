require "test_helper"
require "helpers/network_helper"

describe "Fog::OpenStack::Network | lb_member" do
  describe "success" do
    before do
      @instance = network.lb_members.create(
        :pool_id        => 'pool_id',
        :address        => '10.0.0.1',
        :protocol_port  => 80,
        :weight         => 100,
        :admin_state_up => true,
        :tenant_id      => 'tenant_id'
      )
    end

    it "#create" do
      @instance.id.wont_be_nil
    end

    it "#update" do
      @instance.pool_id = 'new_pool_id'
      @instance.weight = 50
      @instance.admin_state_up = false
      @instance.update.status.must_equal "ACTIVE"
    end

    it "#destroy" do
      @instance.destroy.must_equal true
    end
  end
end
