require "test_helper"

describe "Fog::OpenStack::Storage, ['openstack', 'storage']" do
  before do
    @storage = Fog::OpenStack::Storage.new
    @original_path = @storage.instance_variable_get :@path
  end

  describe "account changes" do
    it "#change_account" do
      new_account = 'AUTH_1234567890'
      @storage.change_account new_account
      @storage.instance_variable_get(:@path) != @original_path
    end

    it "#reset_account_name" do
      @storage.reset_account_name
      @storage.instance_variable_get(:@path) == @original_path
    end
  end
end
