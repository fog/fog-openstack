require "test_helper"

describe "Fog::OpenStack::Baremetal | Baremetal driver requests" do
  before do
    @baremetal = Fog::OpenStack::Baremetal.new

    @driver_format = {
      'hosts' => Array,
      'name'  => String
    }

    @driver_properties_format = {
      "pxe_deploy_ramdisk"   => String,
      "ipmi_transit_address" => String,
      "ipmi_terminal_port"   => String,
      "ipmi_target_channel"  => String,
      "ipmi_transit_channel" => String,
      "ipmi_local_address"   => String,
      "ipmi_username"        => String,
      "ipmi_address"         => String,
      "ipmi_target_address"  => String,
      "ipmi_password"        => String,
      "pxe_deploy_kernel"    => String,
      "ipmi_priv_level"      => String,
      "ipmi_bridging"        => String
    }

    @instances = @baremetal.list_drivers.body
    @instance = @instances['drivers'].last
  end

  describe "success" do
    it "#list_drivers" do
      @instances.must_match_schema('drivers' => [@driver_format])
    end

    it "#get_driver" do
      @baremetal.get_driver(@instance['name']).body.must_match_schema(@driver_format)
    end

    it "#get_driver_properties" do
      @baremetal.get_driver_properties(@instance['name']).body.
        must_match_schema(@driver_properties_format)
    end
  end
end
