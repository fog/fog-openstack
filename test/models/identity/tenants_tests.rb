require "test_helper"

describe "Fog::Compute[:openstack] | tenants" do
  before do
    @identity = Fog::Identity[:openstack]
    @instance = @identity.tenants.create(:name => 'test')
  end

  describe "success" do
    it "#find_by_id" do
      tenant = @identity.tenants.find_by_id(@instance.id)
      tenant.id.must_equal @instance.id
    end

    it "#destroy" do
      @identity.tenants.destroy(@instance.id).must_equal true
    end
  end

  describe "failure" do
    it "#find_by_id" do
      unless Fog.mocking?
        proc do
          @identity.tenants.find_by_id('fake')
        end.must_raise(Fog::Identity::OpenStack::NotFound)
      end
    end

    it "#destroy" do
      unless Fog.mocking?
        proc do
          @identity.tenants.destroy('fake')
        end.must_raise(Fog::Identity::OpenStack::NotFound)
      end
    end
  end
end
