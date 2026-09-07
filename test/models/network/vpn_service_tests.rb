require "test_helper"
require "helpers/network_helper"

describe "Fog::OpenStack::Network | vpn_service" do
  describe "success" do
    before do
      @instance = network.vpn_services.create(
        :subnet_id      => 'foo',
        :router_id      => 'bar',
        :name           => 'test',
        :description    => 'test',
        :admin_state_up => true,
        :tenant_id      => 'tenant'
      )
    end

    it "#create" do
      _(@instance.status).must_equal "ACTIVE"
    end

    it "#update" do
      @instance.subnet_id      = 'new'
      @instance.router_id      = 'new'
      @instance.name           = 'rename'
      @instance.description    = 'new'
      @instance.admin_state_up = false
      @instance.tenant_id      = 'baz'
      _(@instance.update.status).must_equal "ACTIVE"
    end

    it "#destroy" do
      _(@instance.destroy).must_equal true
    end
  end
end
