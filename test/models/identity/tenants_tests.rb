require "test_helper"

describe "Fog::OpenStack::Compute | tenants" do
  before do
    @identity = Fog::OpenStack::Identity.new(:openstack_identity_api_version => 'v2.0')
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
        end.must_raise(Fog::OpenStack::Identity::NotFound)
      end
    end

    it "#destroy" do
      unless Fog.mocking?
        proc do
          @identity.tenants.destroy('fake')
        end.must_raise(Fog::OpenStack::Identity::NotFound)
      end
    end
  end
end
