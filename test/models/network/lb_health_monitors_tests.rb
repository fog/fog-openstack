require "test_helper"
require "helpers/network_helper"

describe "Fog::OpenStack::Network | lb_health_monitors" do
  before do
    @lb_health_monitor = network.lb_health_monitors.create(
      :type        => 'PING',
      :delay       => 1,
      :timeout     => 5,
      :max_retries => 10
    )
    @lb_health_monitors = network.lb_health_monitors
  end

  after do
    @lb_health_monitor.destroy
  end

  describe "success" do
    it "#all" do
      @lb_health_monitors.all[0].status.must_equal "ACTIVE"
    end

    it "#get" do
      @lb_health_monitors.get(@lb_health_monitor.id).status.must_equal "ACTIVE"
    end
  end
end
