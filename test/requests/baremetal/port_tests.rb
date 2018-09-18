require "test_helper"

describe "Fog::OpenStack::Baremetal | Baremetal port requests" do
  before do
    @baremetal = Fog::OpenStack::Baremetal.new

    @port_format = {
      'address' => String,
      'uuid'    => String
    }

    @detailed_port_format = {
      'address'    => String,
      'uuid'       => String,
      'created_at' => String,
      'updated_at' => Fog::Nullable::String,
      'extra'      => Hash,
      'node_uuid'  => String,
      'links'      => Array
    }
  end

  describe "success" do
    it "#list_ports" do
      @baremetal.list_ports.body.must_match_schema('ports' => [@port_format])
    end

    it "#list_ports_detailed" do
      @baremetal.list_ports_detailed.body.must_match_schema('ports' => [@detailed_port_format])
    end

    before do
      node_attributes = {:driver => 'pxe_ipmitool'}
      @instance = Fog::OpenStack::Baremetal.new.create_node(node_attributes).body

      port_attributes = {
        :address   => '00:c2:08:85:de:ca',
        :node_uuid => @instance['uuid']
      }
      @port = Fog::OpenStack::Baremetal.new.create_port(port_attributes).body
    end

    it "#create_port" do
      @port.must_match_schema(@detailed_port_format)
    end

    it "#get_port" do
      @baremetal.get_port(@port['uuid']).body.must_match_schema(@detailed_port_format)
    end

    it "#patch_port" do
      @baremetal.patch_port(
        @port['uuid'],
        [{'op' => 'add', 'path' => '/extra/name', 'value' => 'eth1'}]
      ).body.must_match_schema(@detailed_port_format)
    end

    it "#delete_port" do
      @baremetal.delete_port(@port['uuid']).status.must_equal 200
      @baremetal.delete_node(@instance['uuid']).status.must_equal 200
    end
  end
end
