require "test_helper"
require "helpers/nfv_helper"

describe "Fog::NFV[:openstack] | vnf" do
  describe "success" do
    before do
      @nfv, @vnf_data, @auth = set_nfv_data
      @vnfd = @nfv.vnfds.create(:vnfd => @vnfd_data, :auth => @auth)
      vnf_data = {:vnfd_id => @vnfd.id, :name => 'Test'}
      @vnfs = @nfv.vnfs.create(:vnf => vnf_data, :auth => @auth)
    end

    after do
      @nfv.vnfs.get(@vnfs.id).wait_for { ready? } unless Fog.mocking?
    end

    it "#create" do
      @vnfs.status.must_equal "ACTIVE"
    end

    it "#update" do
      @vnfs.vnf = {:attributes => {:config => "vdus:\n  vdu1:<sample_vdu_config> \n\n"}}
      @vnfs.update.status.must_equal "ACTIVE"
    end

    it "#destroy" do
      sleep(10) unless Fog.mocking?

      @vnfs.destroy
      @vnfd.destroy.must_equal true
    end
  end
end
