require "test_helper"
require "helpers/nfv_helper"

describe "@vnfd | NFV vnfds requests" do
  before do
    @vnfds = {
      "service_types" => Array,
      "description"   => String,
      "tenant_id"     => String,
      "mgmt_driver"   => String,
      "infra_driver"  => String,
      "attributes"    => Hash,
      "id"            => String,
      "name"          => String
    }
    @nfv, @vnf_data, @auth = set_nfv_data
    @vnfd_body = @nfv.create_vnfd(:vnfd => @vnfd_data, :auth => @auth).body
  end

  describe "success" do
    it "#create_vnfds" do
      @vnfd_body.must_match_schema('vnfd' => @vnfds)
    end

    it "#list_vnfds" do
      @nfv.list_vnfds.body.must_match_schema('vnfds' => [@vnfds])
    end

    it "#get_vnfds" do
      @nfv.get_vnfd(@vnfd_body["vnfd"]["id"]).body.must_match_schema('vnfd' => @vnfds)
    end

    it "#delete_vnfds" do
      @nfv.delete_vnfd(@vnfd_body["vnfd"]["id"]).status.must_equal 204
    end
  end
end
