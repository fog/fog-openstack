require "test_helper"

describe "Fog::Identity[:openstack] | ec2_credentials" do
  before do
    identity = Fog::OpenStack::Identity.new(:openstack_identity_api_version => 'v2.0')
    tenant_id = identity.list_tenants.body['tenants'].first['id']

    @user = identity.users.find { |user| user.name == 'foobar' }
    @user ||= identity.users.create(
      :name      => 'foobar',
      :email     => 'foo@bar.com',
      :tenant_id => tenant_id,
      :password  => 'spoof',
      :enabled   => true
    )

    @ec2_credential = identity.ec2_credentials.create(
      :user_id   => @user.id,
      :tenant_id => tenant_id
    )
  end

  after do
    @user.ec2_credentials.each(&:destroy)
    @user.destroy
  end

  describe "success" do
    it "#find_by_access_key" do
      ec2_credential =
        @user.ec2_credentials.find_by_access_key(@ec2_credential.access)

      ec2_credential.access.must_equal @ec2_credential.access
    end

    it "#create" do
      @user.ec2_credentials.create.tenant_id.wont_be_empty
    end

    it "#destroy" do
      @user.ec2_credentials.destroy(@ec2_credential.access).must_equal true
    end
  end

  describe "fails" do
    it "#find_by_access_key" do
      unless Fog.mocking?
        proc do
          @user.ec2_credentials.find_by_access_key('fake')
        end.must_raise(Fog::OpenStack::Identity::NotFound)
      end
    end

    it "#destroy" do
      unless Fog.mocking?
        proc do
          @user.ec2_credentials.destroy('fake')
        end.must_raise(Fog::OpenStack::Identity::NotFound)
      end
    end
  end
end
