require "test_helper"
require "helpers/network_helper"

describe "Fog::OpenStack::Network | subnet" do
  describe "success" do
    before do
      @instance = network.subnets.create(
        :name             => 'subnet_name',
        :network_id       => 'net_id',
        :cidr             => '10.2.2.0/24',
        :ip_version       => 4,
        :gateway_ip       => '10.2.2.1',
        :allocation_pools => [],
        :dns_nameservers  => [],
        :host_routes      => [],
        :enable_dhcp      => true,
        :tenant_id        => 'tenant_id'
      )
    end

    it "#create" do
      @instance.id.wont_be_nil
    end

    it "#update" do
      @instance.name = 'new_subnet_name'
      @instance.update.name.must_equal 'new_subnet_name'
    end

    it "#destroy" do
      @instance.destroy.must_equal true
    end
  end
end
