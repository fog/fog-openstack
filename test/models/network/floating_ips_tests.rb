require "test_helper"
require "helpers/network_helper"

describe "Fog::OpenStack::Network | floating_ips" do
  before do
    @floating_ip = network.floating_ips.create(
      :floating_network_id => 'f0000000-0000-0000-0000-000000000000'
    )
    @floating_ips = network.floating_ips
  end

  after do
    network.delete_floating_ip(@floating_ip.id)
  end

  describe "success" do
    it "#all" do
      @floating_ips.all[0].id.wont_be_nil
    end

    it "#get" do
      # Something wrong here - Test fails when there are several floating ips
      # not properly garbage collected
      skip
      @floating_ips.get(@floating_ip.id).id.must_equal @floating_ip.id
    end
  end
end
