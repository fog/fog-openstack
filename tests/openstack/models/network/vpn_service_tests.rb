Shindo.tests("Fog::Network[:openstack] | vpn_service", ['openstack']) do
  tests('success') do
    tests('#create').succeeds do
      @instance = Fog::Network[:openstack].vpn_services.create(:subnet_id      => 'foo',
                                                               :router_id      => 'bar',
                                                               :name           => 'test',
                                                               :description    => 'test',
                                                               :admin_state_up => true,
                                                               :tenant_id      => 'tenant')
      !@instance.id.nil?
    end

    tests('#update').succeeds do
      @instance.subnet_id      = 'new'
      @instance.router_id      = 'new'
      @instance.name           = 'rename'
      @instance.description    = 'new'
      @instance.admin_state_up = false
      @instance.tenant_id      = 'baz'
      @instance.update
    end

    tests('#destroy').succeeds do
      @instance.destroy == true
    end
  end
end
