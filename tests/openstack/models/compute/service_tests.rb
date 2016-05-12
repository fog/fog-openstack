Shindo.tests("Fog::Compute[:openstack] | services", ['openstack']) do
  tests('success') do
    tests('#all').succeeds do
      services = Fog::Compute[:openstack].services.all
      @service = services.first
    end

    tests('#get').succeeds do
      service = Fog::Compute[:openstack].services.get(@service.id)
      %w(id binary host).all? do |attr|
        attr1 = service.send(attr.to_sym)
        attr2 = @service.send(attr.to_sym)
        attr1 == attr2
      end
    end
  end
end
