require "test_helper"

describe "Fog::Identity[:openstack] | role" do
  before do
    @identity = Fog::OpenStack::Identity.new(:openstack_identity_api_version => 'v2.0')
    @instance = @identity.roles.new(
      :name    => 'Role Name',
      :user_id => 1,
      :role_id => 1
    )
    @tenant   = @identity.tenants.create(:name => 'test_user')
    @user     = @identity.users.create(
      :name      => 'test_user',
      :tenant_id => @tenant.id,
      :password  => 'spoof'
    )
    @instance_saved = @instance.save
  end

  after do
    @user.destroy
    @tenant.destroy
  end

  describe "success" do
    it "#save" do
      @instance_saved.must_equal true
    end

    it "#add_to_user(@user.id, @tenant.id)" do
      @instance.add_to_user(@user.id, @tenant.id).must_equal true
    end

    it "#remove_to_user(@user.id, @tenant.id)" do
      @instance.remove_to_user(@user.id, @tenant.id).must_equal true
    end

    it "#destroy" do
      @instance.destroy.must_equal(true)
    end
  end
end
