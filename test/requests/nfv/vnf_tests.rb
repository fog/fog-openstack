require "test_helper"
require "helpers/nfv_helper"

describe "@vnf | NFV vnfs requests" do
  before do
    @vnfs_create = {
      "status"      => String,
      "description" => String,
      "tenant_id"   => String,
      "name"        => String,
      "instance_id" => String,
      "mgmt_url"    => Fog::Nullable::String,
      "attributes"  => Hash,
      "id"          => String,
      "vnfd_id"     => String
    }

    @vnfs = {
      "status"      => String,
      "description" => String,
      "tenant_id"   => String,
      "name"        => String,
      "instance_id" => String,
      "mgmt_url"    => Fog::Nullable::String,
      "attributes"  => Hash,
      "id"          => String
    }

    @nfv, @vnf_data, @auth = set_nfv_data
    @vnfd_body = @nfv.create_vnfd(:vnfd => @vnfd_data, :auth => @auth).body

    vnf_data  = {:vnfd_id => @vnfd_body["vnfd"]["id"], :name => 'Test'}
    @vnf_body = @nfv.create_vnf(:vnf => vnf_data, :auth => @auth).body

    @nfv.vnfs.get(@vnf_body["vnf"]["id"]).wait_for { ready? }
  end

  describe "success" do
    it "#create_vnfs" do
      @vnf_body.must_match_schema('vnf' => @vnfs_create)
    end

    it "#list_vnfs" do
      @nfv.list_vnfs.body.must_match_schema('vnfs' => [@vnfs])
    end

    it "#get_vnfs" do
      @nfv.get_vnf(@vnf_body["vnf"]["id"]).body.must_match_schema('vnf' => @vnfs)
    end

    describe "inter2" do
      it "#update_vnfs" do
        vnf_data = {:attributes => {:config => "vdus:\n  vdu1:<sample_vdu_config> \n\n"}}
        auth = {"tenantName" => "admin", "passwordCredentials" => {"username" => "admin", "password" => "password"}}
        @nfv.update_vnf(@vnf_body["vnf"]["id"], :vnf => vnf_data, :auth => auth).body.must_match_schema('vnf' => @vnfs)
      end

      it "#delete_vnfs" do
        sleep(10) unless Fog.mocking?

        @nfv.delete_vnf(@vnf_body["vnf"]["id"]).status.must_equal 204
        @nfv.delete_vnfd(@vnfd_body["vnfd"]["id"]).status.must_equal 204
      end
    end
  end
end
