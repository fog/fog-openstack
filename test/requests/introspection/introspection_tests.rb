require "test_helper"

describe "Fog::OpenStack::Introspection | Introspection requests" do
  before do
    @inspector = Fog::OpenStack::Introspection.new

    @node_uuid = Fog::UUID.uuid

    @introspection_finished = {
      "error"    => "null",
      "finished" => "true"
    }

    @introspection_data = {
      "cpu_arch"       => String,
      "macs"           => Array,
      "root_disk"      => {
        "rotational"           => Fog::Boolean,
        "vendor"               => String,
        "name"                 => String,
        "wwn_vendor_extension" => Fog::Nullable::String,
        "wwn_with_extension"   => Fog::Nullable::String,
        "model"                => Fog::Nullable::String,
        "wwn"                  => Fog::Nullable::String,
        "serial"               => Fog::Nullable::String,
        "size"                 => Integer,
      },
      "extra"          => {
        "network"  => {
          "eth0" => {
            "vlan-challenged"                                  => String,
            "tx-udp_tnl-segmentation"                          => String,
            "ipv4-network"                                     => String,
            "rx-vlan-stag-filter"                              => String,
            "highdma"                                          => String,
            "tx-nocache-copy"                                  => String,
            "tx-gso-robust"                                    => String,
            "fcoe-mtu"                                         => String,
            "netns-local"                                      => String,
            "udp-fragmentation-offload"                        => String,
            "serial"                                           => String,
            "latency"                                          => Integer,
            "tx-checksumming/tx-checksum-ipv6"                 => String,
            "tx-checksumming/tx-checksum-ipv4"                 => String,
            "ipv4-netmask"                                     => String,
            "tcp-segmentation-offload/tx-tcp-segmentation"     => String,
            "tx-ipip-segmentation"                             => String,
            "rx-vlan-offload"                                  => String,
            "tx-gre-segmentation"                              => String,
            "tx-checksumming/tx-checksum-ip-generic"           => String,
            "tcp-segmentation-offload/tx-tcp-ecn-segmentation" => String,
            "tx-checksumming/tx-checksum-fcoe-crc"             => String,
            "ipv4"                                             => String,
            "businfo"                                          => String,
            "rx-vlan-stag-hw-parse"                            => String,
            "tx-vlan-offload"                                  => String,
            "product"                                          => String,
            "vendor"                                           => String,
            "tx-checksumming/tx-checksum-sctp"                 => String,
            "driver"                                           => String,
            "tx-sit-segmentation"                              => String,
            "busy-poll"                                        => String,
            "tx-vlan-stag-hw-insert"                           => String,
            "scatter-gather/tx-scatter-gather"                 => String,
            "link"                                             => String,
            "ntuple-filters"                                   => String,
            "rx-all"                                           => String,
            "tcp-segmentation-offload"                         => String,
            "tcp-segmentation-offload/tx-tcp6-segmentation"    => String,
            "rx-checksumming"                                  => String,
            "rx-fcs"                                           => String,
            "tx-lockless"                                      => String,
            "generic-segmentation-offload"                     => String,
            "tx-fcoe-segmentation"                             => String,
            "tx-checksumming"                                  => String,
            "ipv4-cidr"                                        => Integer,
            "large-receive-offload"                            => String,
            "rx-vlan-filter"                                   => String,
            "receive-hashing"                                  => String,
            "scatter-gather/tx-scatter-gather-fraglist"        => String,
            "generic-receive-offload"                          => String,
            "loopback"                                         => String,
            "scatter-gather"                                   => String,
            "tx-mpls-segmentation"                             => String
          },
          "eth1" => {
            "vlan-challenged"                                  => String,
            "tx-udp_tnl-segmentation"                          => String,
            "tx-vlan-stag-hw-insert"                           => String,
            "rx-vlan-stag-filter"                              => String,
            "highdma"                                          => String,
            "tx-nocache-copy"                                  => String,
            "tx-gso-robust"                                    => String,
            "fcoe-mtu"                                         => String,
            "netns-local"                                      => String,
            "udp-fragmentation-offload"                        => String,
            "serial"                                           => String,
            "latency"                                          => Integer,
            "tx-checksumming/tx-checksum-ipv6"                 => String,
            "tx-checksumming/tx-checksum-ipv4"                 => String,
            "tx-fcoe-segmentation"                             => String,
            "tcp-segmentation-offload/tx-tcp-segmentation"     => String,
            "tx-ipip-segmentation"                             => String,
            "rx-vlan-offload"                                  => String,
            "tx-gre-segmentation"                              => String,
            "tx-checksumming/tx-checksum-ip-generic"           => String,
            "tcp-segmentation-offload/tx-tcp-ecn-segmentation" => String,
            "tx-checksumming/tx-checksum-fcoe-crc"             => String,
            "rx-vlan-stag-hw-parse"                            => String,
            "businfo"                                          => String,
            "tx-vlan-offload"                                  => String,
            "product"                                          => String,
            "vendor"                                           => String,
            "tx-checksumming/tx-checksum-sctp"                 => String,
            "driver"                                           => String,
            "tx-sit-segmentation"                              => String,
            "busy-poll"                                        => String,
            "scatter-gather/tx-scatter-gather"                 => String,
            "link"                                             => String,
            "ntuple-filters"                                   => String,
            "rx-all"                                           => String,
            "tcp-segmentation-offload"                         => String,
            "tcp-segmentation-offload/tx-tcp6-segmentation"    => String,
            "rx-checksumming"                                  => String,
            "tx-lockless"                                      => String,
            "generic-segmentation-offload"                     => String,
            "loopback"                                         => String,
            "tx-checksumming"                                  => String,
            "large-receive-offload"                            => String,
            "rx-vlan-filter"                                   => String,
            "receive-hashing"                                  => String,
            "scatter-gather/tx-scatter-gather-fraglist"        => String,
            "generic-receive-offload"                          => String,
            "rx-fcs"                                           => String,
            "scatter-gather"                                   => String,
            "tx-mpls-segmentation"                             => String
          }
        },
        "firmware" => {
          "bios" => {
            "date"    => String,
            "version" => String,
            "vendor"  => String
          }
        },
        "system"   => {
          "kernel"  => {
            "cmdline" => String,
            "version" => String,
            "arch"    => String
          },
          "product" => {
            "version" => String,
            "vendor"  => String,
            "name"    => String,
            "uuid"    => String
          },
          "os"      => {
            "version" => String,
            "vendor"  => String
          }
        },
        "memory"   => {
          "total" => {
            "size" => Integer
          }
        },
        "disk"     => {
          "vda"     => {
            "optimal_io_size"     => Integer,
            "physical_block_size" => Integer,
            "rotational"          => Integer,
            "vendor"              => String,
            "size"                => Integer
          },
          "logical" => {"count" => Integer}
        },
        "cpu"      => {
          "logical"    => {"number" => Integer},
          "physical_0" => {
            "physid"    => Integer,
            "product"   => String,
            "frequency" => Integer,
            "vendor"    => String,
            "flags"     => String
          },
          "physical_1" => {
            "physid"    => Integer,
            "product"   => String,
            "frequency" => Integer,
            "vendor"    => String,
            "flags"     => String
          },
          "physical_2" => {
            "physid"    => Integer,
            "product"   => String,
            "frequency" => Integer,
            "vendor"    => String,
            "flags"     => String
          },
          "physical_3" => {
            "physid"    => Integer,
            "product"   => String,
            "frequency" => Integer,
            "vendor"    => String,
            "flags"     => String
          },
          "physical"   => {"number" => Integer}
        }
      },
      "interfaces"     => {
        "eth0" => {
          "ip"  => String,
          "mac" => String
        }
      },
      "cpus"           => 4,
      "boot_interface" => String,
      "memory_mb"      => Integer,
      "ipmi_address"   => String,
      "inventory"      => {
        "bmc_address"   => String,
        "interfaces"    => [
          {
            "ipv4_address"         => Fog::Nullable::String,
            "switch_port_descr"    => Fog::Nullable::String,
            "switch_chassis_descr" => Fog::Nullable::String,
            "name"                 => String,
            "mac_address"          => String
          },
          {
            "ipv4_address"         => Fog::Nullable::String,
            "switch_port_descr"    => Fog::Nullable::String,
            "switch_chassis_descr" => Fog::Nullable::String,
            "name"                 => String,
            "mac_address"          => String
          }
        ],
        "disks"         => [
          {
            "rotational"           => Fog::Boolean,
            "vendor"               => String,
            "name"                 => String,
            "wwn_vendor_extension" => Fog::Nullable::String,
            "wwn_with_extension"   => Fog::Nullable::String,
            "model"                => Fog::Nullable::String,
            "wwn"                  => Fog::Nullable::String,
            "serial"               => Fog::Nullable::String,
            "size"                 => Integer
          }
        ],
        "system_vendor" => {
          "serial_number" => String,
          "product_name"  => String,
          "manufacturer"  => String
        },
        "memory"        => {
          "physical_mb" => Integer,
          "total"       => Integer
        },
        "cpu"           => {
          "count"        => Integer,
          "frequency"    => String,
          "model_name"   => String,
          "architecture" => String
        }
      },
      "error"          => Fog::Nullable::String,
      "local_gb"       => Integer,
      "all_interfaces" => {
        "eth0" => {
          "ip"  => Fog::Nullable::String,
          "mac" => String
        },
        "eth1" => {
          "ip"  => Fog::Nullable::String,
          "mac" => String
        }
      },
      "logs"           => String
    }
  end

  describe "success" do
    it "#create_introspection" do
      @inspector.create_introspection(@node_uuid).status.must_equal 202
    end

    it "#abort_introspection" do
      @inspector.abort_introspection(@node_uuid).status.must_equal 202
    end

    it "#get_introspection" do
      @inspector.get_introspection(@node_uuid).body.must_match_schema(@introspection_finished)
    end

    it "#get_introspection_details" do
      @inspector.get_introspection_details(@node_uuid).body.must_match_schema('data' => @introspection_data)
    end
  end
end
