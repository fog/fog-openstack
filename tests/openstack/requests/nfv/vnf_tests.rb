Shindo.tests('@vnf | NFV vnfs requests', ['openstack']) do
  @nfv = Fog::NFV::OpenStack.new

  @vnfs_create = {
    "status"      => String,
    "description" => String,
    "tenant_id"   => String,
    "name"        => String,
    "instance_id" => String,
    "mgmt_url"    => Fog::Nullable::String,
    "attributes"  => Hash,
    "id"          => String,
    "vnfd_id"     => String,
  }

  @vnfs = {
    "status"      => String,
    "description" => String,
    "tenant_id"   => String,
    "name"        => String,
    "instance_id" => String,
    "mgmt_url"    => Fog::Nullable::String,
    "attributes"  => Hash,
    "id"          => String,
  }

  tests('success') do
    tests('#create_vnfs').data_matches_schema('vnf' => @vnfs_create) do
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
      vnf_data   = {:vnfd_id => @vnfd_body["vnfd"]["id"], :name => 'Test'}
      auth       = {"tenantName" => "admin", "passwordCredentials" => {"username" => "admin", "password" => "password"}}
      @vnf_body  = @nfv.create_vnf(:vnf => vnf_data, :auth => auth).body
    end

    Fog::NFV[:openstack].vnfs.get(@vnf_body["vnf"]["id"]).wait_for { ready? }

    tests('#list_vnfs').data_matches_schema('vnfs' => [@vnfs]) do
      @nfv.list_vnfs.body
    end

    tests('#get_vnfs').data_matches_schema('vnf' => @vnfs) do
      @nfv.get_vnf(@vnf_body["vnf"]["id"]).body
    end

    tests('#update_vnfs').data_matches_schema('vnf' => @vnfs) do
      vnf_data = {:attributes => {:config => "vdus:\n  vdu1:<sample_vdu_config> \n\n"}}
      auth     = {"tenantName" => "admin", "passwordCredentials" => {"username" => "admin", "password" => "password"}}
      @nfv.update_vnf(@vnf_body["vnf"]["id"], :vnf => vnf_data, :auth => auth).body
    end

    tests('#delete_vnfs').succeeds do
      sleep(10) unless Fog.mocking?

      @nfv.delete_vnf(@vnf_body["vnf"]["id"])
      @nfv.delete_vnfd(@vnfd_body["vnfd"]["id"])
    end
  end
end
