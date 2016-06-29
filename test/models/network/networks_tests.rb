require "test_helper"

describe "Fog::Network[:openstack] | networks" do
  before do
    @network = network.networks.create(
      :name           => 'net_name',
      :shared         => false,
      :admin_state_up => true,
      :tenant_id      => 'tenant_id'
    )

    @networks = network.networks
  end

  after do
    @network.destroy
  end

  describe "success" do
    it "#all" do
      @networks.all[0].status.must_equal "ACTIVE"
    end

    it "#get" do
      @networks.get(@network.id).status.must_equal "ACTIVE"
    end
  end
end
