require "test_helper"
require "helpers/nfv_helper"

describe "Fog::NFV[:openstack] | vnf" do
  describe "success" do
    before do
      @nfv, @vnf_data, @auth = set_nfv_data
      @vnfd = @nfv.vnfds.create(:vnfd => @vnfd_data, :auth => @auth)
    end

    it "#create" do
      @vnfd.id.wont_be_empty
    end

    it "#destroy" do
      @vnfd.destroy.must_equal true
    end
  end
end
