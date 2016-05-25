require "test_helper"

describe "Fog::Network[:openstack] | floating_ip" do
  describe "success" do
    before do
      @instance = Fog::Network[:openstack].floating_ips.create(
        :floating_network_id => 'f0000000-0000-0000-0000-000000000000'
      )
    end

    it "#create" do
      @instance.id.wont_be_nil
    end

    it "#update" do
      @instance.port_id = 'p0000000-0000-0000-0000-000000000000'
      @instance.update.port_id.must_equal "p0000000-0000-0000-0000-000000000000"
    end

    it "#associate" do
      port_id = 'p0000000-0000-0000-0000-000000000000'
      fixed_ip_address = '8.8.8.8'
      @instance.associate(port_id, fixed_ip_address)
      @instance.port_id.must_equal port_id
      @instance.fixed_ip_address.must_equal fixed_ip_address
    end

    it "#disassociate" do
      fixed_ip_address = '8.8.8.8'
      @instance.disassociate(fixed_ip_address)
      @instance.port_id.must_equal nil
      @instance.fixed_ip_address.must_equal nil
    end

    it "#destroy" do
      skip
      instance = Fog::Network[:openstack].floating_ips.create(
        :floating_network_id => 'f0000000-0000-0000-0000-000000000000'
      )
      instance.destroy == true
    end

    after do
      Fog::Network[:openstack].delete_floating_ip(@instance.id)
    end
  end
end
