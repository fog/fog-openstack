require "test_helper"
require "helpers/network_helper"

describe "Fog::OpenStack::Network | subnets" do
  describe "success" do
    before do
      @subnet = network.subnets.create(
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

      @subnets = network.subnets
    end

    after do
      @subnet.destroy
    end

    it "#all" do
      @subnets.all[0].id.wont_be_empty
    end

    it "#get" do
      @subnets.get(@subnet.id).id.wont_be_empty
    end
  end
end
