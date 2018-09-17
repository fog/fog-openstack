require "test_helper"
require "helpers/network_helper"

describe "Fog::OpenStack::Network | vpn_services" do
  before do
    @vpn_service = network.vpn_services.create(
      :subnet_id      => 'foo',
      :router_id      => 'bar',
      :name           => 'test',
      :description    => 'test',
      :admin_state_up => true,
      :tenant_id      => 'tenant'
    )

    @vpn_services = network.vpn_services
  end

  after do
    @vpn_service.destroy
  end

  describe "success" do
    it "#all" do
      @vpn_services.all[0].status.must_equal "ACTIVE"
    end

    it "#get" do
      @vpn_services.get(@vpn_service.id).status.must_equal "ACTIVE"
    end
  end
end
