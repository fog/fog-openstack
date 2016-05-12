Shindo.tests("Fog::NFV[:openstack] | vnfs", ['openstack']) do
  vnfd_data = {:attributes    => {:vnfd => "template_name: sample-vnfd\ndescription: demo-example\n\nservice_prop"\
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
  auth      = {"tenantName" => "admin", "passwordCredentials" => {"username" => "admin", "password" => "password"}}
  @vnfd     = Fog::NFV[:openstack].vnfds.create(:vnfd => vnfd_data, :auth => auth)

  tests('success') do
    tests('#find_by_id').succeeds do
      vnf = Fog::NFV[:openstack].vnfds.find_by_id(@vnfd.id)
      vnf.id == @vnfd.id
    end

    tests('#get').succeeds do
      vnf = Fog::NFV[:openstack].vnfds.get(@vnfd.id)
      vnf.id == @vnfd.id
    end

    tests('#destroy').succeeds do
      Fog::NFV[:openstack].vnfds.destroy(@vnfd.id)
    end
  end
end
