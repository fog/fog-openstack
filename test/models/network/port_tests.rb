require "test_helper"
require "helpers/network_helper"

describe "Fog::OpenStack::Network | port" do
  describe "success" do
    before do
      @instance = network.ports.create(
        :name           => 'port_name',
        :network_id     => 'net_id',
        :fixed_ips      => [],
        :mac_address    => 'fa:16:3e:62:91:7f',
        :admin_state_up => true,
        :device_owner   => 'device_owner',
        :device_id      => 'device_id',
        :tenant_id      => 'tenant_id'
      )
    end

    it "#create" do
      @instance.id.wont_be_nil
    end

    it "#update" do
      @instance.name = 'new_port_name'
      @instance.update.status.must_equal "ACTIVE"
    end

    it "#destroy" do
      @instance.destroy.must_equal true
    end
  end
end
