require "test_helper"

describe "Fog::Identity[:openstack] | ec2_credential" do
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
    @user.ec2_credentials.each do |ec2_credential|
      ec2_credential.destroy
    end

    @user.destroy
  end

  describe "success" do
    it "#destroy" do
      @ec2_credential.destroy.must_equal(true)
    end
  end

  describe "failure" do
    it "#save" do
      proc do
        @ec2_credential.save
      end.must_raise(Fog::Errors::Error)
    end
  end
end
