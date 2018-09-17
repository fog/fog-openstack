require "test_helper"

require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

describe "Fog::OpenStack::Compute | flavor requests" do
  before do
    @flavor_format = {
      'id'                         => String,
      'name'                       => String,
      'disk'                       => Integer,
      'ram'                        => Integer,
      'links'                      => Array,
      'swap'                       => Fog::Nullable::String,
      'rxtx_factor'                => Fog::Nullable::Float,
      'OS-FLV-EXT-DATA:ephemeral'  => Integer,
      'os-flavor-access:is_public' => Fog::Nullable::Boolean,
      'OS-FLV-DISABLED:disabled'   => Fog::Nullable::Boolean,
      'vcpus'                      => Integer
    }

    @compute = Fog::OpenStack::Compute.new
  end

  describe "success" do
    it "#get_flavor_details(1)" do
      @compute.get_flavor_details("1").body['flavor'].
        must_match_schema(@flavor_format)
    end

    it "#list_flavors" do
      @compute.list_flavors.body.
        must_match_schema('flavors' => [OpenStack::Compute::Formats::SUMMARY])
    end

    it "#list_flavors_detail" do
      @compute.list_flavors_detail.body.
        must_match_schema('flavors' => [@flavor_format])
    end

    it "#create_flavor(attributes)" do
      attributes = {
        :flavor_id   => '100',
        :name        => 'shindo test flavor',
        :disk        => 10,
        :ram         => 10,
        :vcpus       => 10,
        :swap        => "0",
        :rxtx_factor => 2.4,
        :ephemeral   => 0,
        :is_public   => false
      }

      @compute.create_flavor(attributes).body.
        must_match_schema('flavor' => @flavor_format)
    end

    it "add_flavor_access(flavor_ref, tenant_id)" do
      @compute.add_flavor_access(100, 1).body.
        must_match_schema('flavor_access' => [{'tenant_id' => String, 'flavor_id' => String}])
    end

    it "remove_flavor_access(flavor_ref, tenant_id)" do
      @compute.remove_flavor_access(100, 1).body.
        must_match_schema('flavor_access' => [])
    end

    it "list_tenants_with_flavor_access(flavor_ref)" do
      @compute.list_tenants_with_flavor_access(100).body.
        must_match_schema('flavor_access' => [{'tenant_id' => String, 'flavor_id' => String}])
    end

    it "delete_flavor(flavor_id)" do
      @compute.delete_flavor('100').status.must_equal 202
    end

    it "#get_flavor_metadata(flavor_ref)" do
      @compute.get_flavor_metadata("1").body.
        must_match_schema('extra_specs' => {'cpu_arch' => String})
    end

    it "#create_flavor_metadata(flavor_ref, metadata)" do
      metadata = {:cpu_arch => 'x86_64'}
      @compute.create_flavor_metadata("1", metadata).body.
        must_match_schema('extra_specs' => {'cpu_arch' => String})
    end
  end

  describe "failure" do
    it "#get_flavor_details(0)" do
      proc do
        @compute.get_flavor_details("0")
      end.must_raise Fog::OpenStack::Compute::NotFound
    end

    it "add_flavor_access(1234, 1)" do
      unless Fog.mocking?
        proc do
          @compute.add_flavor_access(1234, 1).body
        end.must_raise Fog::OpenStack::Compute::NotFound
      end
    end

    it "remove_flavor_access(1234, 1)" do
      unless Fog.mocking?
        proc do
          @compute.remove_flavor_access(1234, 1).body
        end.must_raise Fog::OpenStack::Compute::NotFound
      end
    end

    it "list_tenants_with_flavor_access(1234)" do
      unless Fog.mocking?
        proc do
          @compute.list_tenants_with_flavor_access(1234)
        end.must_raise Fog::OpenStack::Compute::NotFound
      end
    end

    it "get_flavor_metadata(flavor_ref)" do
      unless Fog.mocking?
        proc do
          @compute.get_flavor_metadata("1234").body
        end.must_raise Fog::OpenStack::Compute::NotFound
      end
    end

    it "create_flavor_metadata(flavor_ref)" do
      unless Fog.mocking?
        proc do
          metadata = {:cpu_arch => 'x86_64'}
          @compute.create_flavor_metadata("1234", metadata).body
        end.must_raise Fog::OpenStack::Compute::NotFound
      end
    end
  end
end
