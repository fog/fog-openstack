require "test_helper"

describe "Fog::Network[:openstack] | subnets" do
  describe "success" do
    before do
      @subnet = Fog::Network[:openstack].subnets.create(
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

      @subnets = Fog::Network[:openstack].subnets
    end

    it "#all" do
      @subnets.all[0].id.wont_be_empty
    end

    it "#get" do
      @subnets.get(@subnet.id).id.wont_be_empty
    end

    after do
      @subnet.destroy
    end
  end
end
