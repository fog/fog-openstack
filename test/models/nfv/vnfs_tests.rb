require "test_helper"
require "helpers/nfv_helper"

describe "Fog::NFV[:openstack] | vnfs" do
  describe "success" do
    before do
      @nfv, @vnf_data, @auth = set_nfv_data
      @vnfd = @nfv.vnfds.create(:vnfd => @vnfd_data, :auth => @auth)
      vnf_data = {:vnfd_id => @vnfd.id, :name => 'Test'}
      @vnfs = @nfv.vnfs.create(:vnf => vnf_data, :auth => @auth)

      @nfv.vnfs.get(@vnfs.id).wait_for { ready? } unless Fog.mocking?
    end

    it "#find_by_id" do
      vnf = @nfv.vnfs.find_by_id(@vnfs.id)
      vnf.id.must_equal @vnfs.id
    end

    it "#get" do
      vnf = @nfv.vnfs.get(@vnfs.id)
      vnf.id.must_equal @vnfs.id
    end

    it "#destroy" do
      sleep(10) unless Fog.mocking?

      @nfv.vnfs.destroy(@vnfs.id)
      @nfv.vnfds.destroy(@vnfd.id).must_equal true
    end
  end
end
