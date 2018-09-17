require "test_helper"
require "helpers/network_helper"

describe "Fog::OpenStack::Network | lb_pool" do
  describe "success" do
    before do
      @lb_health_monitor = network.lb_health_monitors.create(
        :type        => 'PING',
        :delay       => 1,
        :timeout     => 5,
        :max_retries => 10
      )

      @instance = network.lb_pools.create(
        :subnet_id      => 'subnet_id',
        :protocol       => 'HTTP',
        :lb_method      => 'ROUND_ROBIN',
        :name           => 'test-pool',
        :description    => 'Test Pool',
        :admin_state_up => true,
        :tenant_id      => 'tenant_id'
      )
    end

    after do
      @lb_health_monitor.destroy
    end

    it "#create" do
      @instance.id.wont_be_nil
    end

    it "#update" do
      @instance.name = 'new-test-pool'
      @instance.description = 'New Test Pool'
      @instance.lb_method = 'LEAST_CONNECTIONS'
      @instance.admin_state_up = false
      @instance.update.status.must_equal "ACTIVE"
    end

    it "#stats" do
      @instance.stats
      @instance.active_connections.wont_be_nil
    end

    it "#associate_health_monitor" do
      @instance.associate_health_monitor(@lb_health_monitor.id).must_equal true
    end

    it "#disassociate_health_monitor" do
      @instance.disassociate_health_monitor(@lb_health_monitor.id).must_equal true
    end

    it "#destroy" do
      @instance.destroy.must_equal true
    end
  end
end
