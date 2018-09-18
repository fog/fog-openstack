require "test_helper"

describe "Fog::OpenStack::Baremetal | Baremetal node requests" do
  before do
    @baremetal = Fog::OpenStack::Baremetal.new
    @node_format = {
      'instance_uuid'   => Fog::Nullable::String,
      'maintenance'     => Fog::Boolean,
      'power_state'     => Fog::Nullable::String,
      'provision_state' => Fog::Nullable::String,
      'uuid'            => String,
      'links'           => Array
    }

    @detailed_node_format = {
      'instance_uuid'          => Fog::Nullable::String,
      'maintenance'            => Fog::Boolean,
      'power_state'            => Fog::Nullable::String,
      'provision_state'        => Fog::Nullable::String,
      'uuid'                   => String,
      'created_at'             => String,
      'updated_at'             => Fog::Nullable::String,
      'chassis_uuid'           => Fog::Nullable::String,
      'console_enabled'        => Fog::Boolean,
      'driver'                 => String,
      'driver_info'            => Hash,
      'extra'                  => Hash,
      'instance_info'          => Hash,
      'last_error'             => Fog::Nullable::String,
      'maintenance_reason'     => Fog::Nullable::String,
      'properties'             => Hash,
      'provision_updated_at'   => Fog::Nullable::String,
      'reservation'            => Fog::Nullable::String,
      'target_power_state'     => Fog::Nullable::String,
      'target_provision_state' => Fog::Nullable::String,
      'links'                  => Array
    }
  end

  describe "success" do
    it "#list_nodes" do
      @baremetal.list_nodes.body.must_match_schema('nodes' => [@node_format])
    end

    it "#list_nodes_detailed" do
      @baremetal.list_nodes_detailed.body.
        must_match_schema('nodes' => [@detailed_node_format])
    end

    before do
      node_attributes = {:driver => 'pxe_ipmitool'}
      @instance = @baremetal.create_node(node_attributes).body
    end

    it "#create_node" do
      @instance.must_match_schema(@detailed_node_format)
    end

    it "#get_node" do
      @baremetal.get_node(@instance['uuid']).body.
        must_match_schema(@detailed_node_format)
    end

    it "#patch_node" do
      @baremetal.patch_node(
        @instance['uuid'],
        [{'op' => 'replace', 'path' => '/driver', 'value' => 'pxe_ssh'}]
      ).body.must_match_schema(@detailed_node_format)
    end

    it "#set_node_power_state" do
      @baremetal.set_node_power_state(@instance['uuid'], 'power off').body.
        must_match_schema(@detailed_node_format)
    end

    it "#set_node_provision_state" do
      @baremetal.set_node_provision_state(@instance['uuid'], 'manage').body.
        must_match_schema(@detailed_node_format)
    end

    it "#set_node_maintenance" do
      @baremetal.set_node_maintenance(@instance['uuid']).status.must_equal 202
    end

    it "#unset_node_maintenance" do
      @baremetal.unset_node_maintenance(@instance['uuid']).status.must_equal 202
    end

    it "#delete_node" do
      @baremetal.delete_node(@instance['uuid']).status.must_equal 200
    end
  end
end
