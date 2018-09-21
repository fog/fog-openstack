require "test_helper"

describe "Fog::Identity[:openstack] | tenant" do
  before do
    @identity = Fog::OpenStack::Identity.new(:openstack_identity_api_version => 'v2.0')
  end

  describe "success" do
    before do
      @instance = @identity.tenants.first
    end

    it "#roles_for(0)" do
      @instance.roles_for(0)
    end

    it "#users" do
      instance = @identity.tenants.first
      instance.users.count.wont_equal @identity.users.count
    end
  end

  describe "CRUD" do
    before do
      @instance = @identity.tenants.create(:name => 'test')
    end

    it "#create" do
      @instance.id.nil?.wont_be_nil
    end

    it "#update" do
      @instance.update(:name => 'test2')
      @instance.name.must_equal 'test2'
    end

    it "#destroy" do
      @instance.destroy.must_equal true
    end
  end
end
