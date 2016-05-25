require "test_helper"
require "helpers/nfv_helper"

describe "Fog::NFV[:openstack] | vnfs" do
  describe "success" do
    before do
      @nfv, @vnf_data, @auth = set_nfv_data
      @vnfd = @nfv.vnfds.create(:vnfd => @vnfd_data, :auth => @auth)
    end

    it "#find_by_id" do
      vnf = @nfv.vnfds.find_by_id(@vnfd.id)
      vnf.id.must_equal @vnfd.id
    end

    it "#get" do
      vnf = @nfv.vnfds.get(@vnfd.id)
      vnf.id.must_equal @vnfd.id
    end

    it "#destroy" do
      @nfv.vnfds.destroy(@vnfd.id).must_equal true
    end
  end
end
