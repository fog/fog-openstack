require "test_helper"

describe "Fog::Identity[:openstack] | user" do
  before do
    @identity = Fog::OpenStack::Identity.new(:openstack_identity_api_version => 'v2.0')
    @tenant_id = @identity.list_tenants.body['tenants'].first['id']
    @instance = @identity.users.new(
      :name      => 'User Name',
      :email     => 'test@fog.com',
      :tenant_id => @tenant_id,
      :password  => 'spoof',
      :enabled   => true
    )
  end

  describe "success" do
    before do
      @instance_saved = @instance.save
    end

    it "#save" do
      _(@instance_saved).must_equal true
    end

    it "#roles" do
      _(@instance.roles).must_be_empty
    end

    it "#update" do
      _(@instance.update(:name => 'updatename', :email => 'new@email.com')).
        must_equal true
    end

    it "#update_password" do
      _(@instance.update_password('swordfish')).must_equal true
    end

    it "#update_tenant" do
      _(@instance.update_tenant(@tenant_id)).must_equal true
    end

    it "#update_enabled" do
      _(@instance.update_enabled(true)).must_equal true
    end

    it "#destroy" do
      _(@instance.destroy).must_equal true
    end
  end

  describe "failure" do
    it "#save" do
      skip
      _(proc do
        @instance.save
      end).must_raise(Fog::Errors::Error)
    end
  end
end
