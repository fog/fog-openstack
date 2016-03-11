Shindo.tests("Fog::Network[:openstack] | vpn_services", ['openstack']) do
  @vpn_service = Fog::Network[:openstack].vpn_services.create(:subnet_id      => 'foo',
                                                              :router_id      => 'bar',
                                                              :name           => 'test',
                                                              :description    => 'test',
                                                              :admin_state_up => true,
                                                              :tenant_id      => 'tenant')

  @vpn_services = Fog::Network[:openstack].vpn_services

  tests('success') do
    tests('#all').succeeds do
      @vpn_services.all
    end

    tests('#get').succeeds do
      @vpn_services.get @vpn_service.id
    end
  end

  @vpn_service.destroy
end
