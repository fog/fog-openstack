Shindo.tests('@vnfd | NFV vnfds requests', ['openstack']) do
  @nfv = Fog::NFV::OpenStack.new

  @vnfds = {
    "service_types" => Array,
    "description"   => String,
    "tenant_id"     => String,
    "mgmt_driver"   => String,
    "infra_driver"  => String,
    "attributes"    => Hash,
    "id"            => String,
    "name"          => String
  }

  tests('success') do
    tests('#create_vnfds').data_matches_schema('vnfd' => @vnfds) do
      vnfd_data  = {:attributes    => {:vnfd => "template_name: sample-vnfd\ndescription: demo-example\n\nservice_prop"\
                                                "erties:\n  Id: sample-vnfd\n  vendor: tacker\n  version: 1\n\nvdus:\n"\
                                                "  vdu1:\n    id: vdu1\n    vm_image: cirros\n    instance_type: m1.ti"\
                                                "ny\n\n    network_interfaces:\n      management:\n        network: ne"\
                                                "t_mgmt\n        management: true\n      pkt_in:\n        network: net"\
                                                "0\n      pkt_out:\n        network: net1\n\n    placement_policy:\n  "\
                                                "    availability_zone: nova\n\n    auto-scaling: noop\n\n    config:"\
                                                "\n      param0: key0\n      param1: key1\n"},
                    :service_types => [{:service_type => "vnfd"}],
                    :mgmt_driver   => "noop",
                    :infra_driver  => "heat"}
      auth       = {"tenantName" => "admin", "passwordCredentials" => {"username" => "admin", "password" => "password"}}
      @vnfd_body = @nfv.create_vnfd(:vnfd => vnfd_data, :auth => auth).body
    end

    tests('#list_vnfds').data_matches_schema('vnfds' => [@vnfds]) do
      @nfv.list_vnfds.body
    end

    tests('#get_vnfds').data_matches_schema('vnfd' => @vnfds) do
      @nfv.get_vnfd(@vnfd_body["vnfd"]["id"]).body
    end

    tests('#delete_vnfds').succeeds do
      @nfv.delete_vnfd(@vnfd_body["vnfd"]["id"])
    end
  end
end
