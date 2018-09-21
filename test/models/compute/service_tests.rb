require "test_helper"

describe "Fog::Compute[:openstack] | services" do
  describe "success" do
    before do
      services = Fog::Compute[:openstack].services.all
      @service = services.first
    end

    it "#all" do
      @service.state.must_equal "up"
    end

    it "#get" do
      service = Fog::Compute[:openstack].services.get(@service.id)
      %w(id binary host).all? do |attr|
        attr1 = service.send(attr.to_sym)
        attr2 = @service.send(attr.to_sym)
        attr1 == attr2
      end.must_equal true
    end
  end
end
