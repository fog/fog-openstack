require "test_helper"
require "helpers/network_helper"

describe "Fog::OpenStack::Network | ports" do
  before do
    @port = network.ports.create(
      :name           => 'port_name',
      :network_id     => 'net_id',
      :fixed_ips      => [],
      :mac_address    => 'fa:16:3e:62:91:7f',
      :admin_state_up => true,
      :device_owner   => 'device_owner',
      :device_id      => 'device_id',
      :tenant_id      => 'tenant_id'
    )

    @ports = network.ports
  end

  after do
    @port.destroy
  end

  describe "success" do
    it "#all" do
      @ports.all[0].status.must_equal "ACTIVE"
    end

    it "#get" do
      @ports.get(@port.id).status.must_equal "ACTIVE"
    end
  end
end
