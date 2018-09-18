require "test_helper"
require "helpers/network_helper"

describe "Fog::OpenStack::Network | network" do
  describe "success" do
    before do
      @instance = network.networks.create(
        :name           => 'net_name',
        :shared         => false,
        :admin_state_up => true,
        :tenant_id      => 'tenant_id'
      )
    end

    it "#create" do
      @instance.id.wont_be_nil
    end

    it "#create+extensions" do
      net = network.networks.create(
        :name                     => 'net_name',
        :shared                   => false,
        :admin_state_up           => true,
        :tenant_id                => 'tenant_id',
        :router_external          => true,
        # local, gre, vlan. Depends on the provider.
        # May rise an exception if the network_type isn't valid:
        # QuantumError: "Invalid input for operation: provider:physical_network"
        :provider_network_type    => 'gre',
        :provider_segmentation_id => 22
      )

      net.status.must_equal "ACTIVE"
      net.destroy
      net.provider_network_type.must_equal 'gre'
    end

    describe "The network model should respond to" do
      before do
        @attributes = [
          :name,
          :subnets,
          :shared,
          :status,
          :admin_state_up,
          :tenant_id,
          :provider_network_type,
          :provider_physical_network,
          :provider_segmentation_id,
          :router_external
        ]
      end

      it "attributes" do
        @attributes.each do |attribute|
          @instance.respond_to?(attribute).must_equal true
        end
      end
    end

    it "#update" do
      @instance.name = 'new_net_name'
      @instance.update.status.must_equal "ACTIVE"
    end

    it "#destroy" do
      @instance.destroy.must_equal true
    end
  end
end
