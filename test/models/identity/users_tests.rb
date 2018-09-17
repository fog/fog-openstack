require "test_helper"

describe "Fog::Identity[:openstack] | users" do
  before do
    @identity = Fog::OpenStack::Identity.new(:openstack_identity_api_version => 'v2.0')
    tenant_id = @identity.list_tenants.body['tenants'].first['id']
    @instance = @identity.users.create(
      :name      => 'foobar',
      :email     => 'foo@bar.com',
      :tenant_id => tenant_id,
      :password  => 'spoof',
      :enabled   => true
    )
  end

  describe "success" do
    it "#find_by_id" do
      user = @identity.users.find_by_id(@instance.id)
      user.id.must_equal @instance.id
    end

    it "#find_by_name" do
      user = @identity.users.find_by_name(@instance.name)
      user.name.must_equal @instance.name
    end

    it "#destroy" do
      @identity.users.destroy(@instance.id).must_equal true
    end
  end

  describe "fails" do
    it "#find_by_id" do
      unless Fog.mocking?
        proc do
          Fog::Identity[:openstack].users.find_by_id('fake')
        end.must_raise(Fog::OpenStack::Identity::NotFound)
      end
    end

    it "#find_by_name" do
      unless Fog.mocking?
        proc do
          Fog::Identity[:openstack].users.find_by_name('fake')
        end.must_raise(Fog::OpenStack::Identity::NotFound)
      end
    end

    it "#destroy" do
      unless Fog.mocking?
        proc do
          Fog::Identity[:openstack].users.destroy('fake')
        end.must_raise(Fog::OpenStack::Identity::NotFound)
      end
    end
  end
end
