require "test_helper"
require "helpers/network_helper"

describe "Fog::OpenStack::Network | floating_ip" do
  describe "success" do
    let (:instance) do
      network.floating_ips.create(
        :floating_network_id => 'f0000000-0000-0000-0000-000000000000'
      )
    end

    after do
      network.delete_floating_ip(instance.id)
    end

    it "#create" do
      instance.id.wont_be_nil
    end

    it "#update" do
      instance.port_id = 'p0000000-0000-0000-0000-000000000000'
      instance.update.port_id.must_equal "p0000000-0000-0000-0000-000000000000"
    end

    describe "#associate" do
      let(:port_id) { 'p0000000-0000-0000-0000-000000000000' }
      let(:fixed_ip_address) { '8.8.8.8' }
      let(:associate) { instance.associate(port_id, fixed_ip_address) }

      it "must match port_id" do
        associate.port_id.must_equal port_id
      end

      it "must match fixed_ip_address" do
        associate.fixed_ip_address.must_equal fixed_ip_address
      end
    end

    describe "#disassociate" do
      let(:fixed_ip_address) { '8.8.8.8' }
      let(:disassociate) { instance.disassociate(fixed_ip_address) }

      it "resets port_id" do
        disassociate.port_id.must_equal nil
      end

      it "resets fixed_ip_address" do
        disassociate.fixed_ip_address.must_equal nil
      end
    end

    it "#destroy" do
      instance = network.floating_ips.create(
        :floating_network_id => 'f0000000-0000-0000-0000-000000000000'
      )
      instance.destroy == true
    end
  end
end
