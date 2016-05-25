require "test_helper"
describe "Fog::Network[:openstack] | lb_health_monitors" do
  before do
    @lb_health_monitor = Fog::Network[:openstack].lb_health_monitors.create(
    :type => 'PING',
    :delay => 1,
    :timeout => 5,
    :max_retries => 10
    )

    @lb_health_monitors = Fog::Network[:openstack].lb_health_monitors
  end

  describe "success" do
    it "#all" do
      @lb_health_monitors.all[0].status.must_equal "ACTIVE"
    end

    it "#get" do
      @lb_health_monitors.get(@lb_health_monitor.id).status.must_equal "ACTIVE"
    end
  end

  after do
    @lb_health_monitor.destroy
  end
end
