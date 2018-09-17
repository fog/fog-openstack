require "test_helper"
require "helpers/network_helper"

describe "Fog::OpenStack::Network | router" do
  describe "success" do
    before do
      @instance = network.routers.create(
        :name           => 'router_name',
        :admin_state_up => true
      )
    end

    it "#create" do
      @instance.id.wont_be_nil
    end

    describe '#update' do
      it "router name" do
        @instance.name = 'new_name'
        @instance.update
        @instance.name.must_equal 'new_name'
      end

      # Needs code from issue #1598
      # it "external_gateway_info" do
      #   net = network.networks.create(
      #     :name => 'net_name',
      #     :shared => false,
      #     :admin_state_up => true,
      #     :tenant_id => 'tenant_id',
      #     :router_external => true,
      #   )
      #   @instance.external_gateway_info = net
      #   @instance.update
      # end
    end

    it "#destroy" do
      @instance.destroy.must_equal true
    end
  end
end
