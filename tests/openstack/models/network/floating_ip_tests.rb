Shindo.tests("Fog::Network[:openstack] | floating_ip", ['openstack']) do

  tests('success') do

    tests('#create').succeeds do
      @instance = Fog::Network[:openstack].floating_ips.create(:floating_network_id => 'f0000000-0000-0000-0000-000000000000')

      !@instance.id.nil?
    end

    tests('#update').succeeds do
      @instance.port_id = 'p0000000-0000-0000-0000-000000000000'
      @instance.update
    end

    tests('#destroy').succeeds do
      @instance.destroy == true
    end

    tests('#associate').succeeds do
      port_id = 'p0000000-0000-0000-0000-000000000000'
      fixed_ip_address = '8.8.8.8'
      @instance.associate(port_id, fixed_ip_address)
      returns(port_id) { @instance.port_id }
      returns(fixed_ip_address) { @instance.fixed_ip_address }
    end

    tests('#disassociate').succeeds do
      fixed_ip_address = '8.8.8.8'
      @instance.disassociate(fixed_ip_address)
      returns(nil) { @instance.port_id }
      returns(nil) { @instance.fixed_ip_address }
    end
  end
end
