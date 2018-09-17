require "test_helper"

describe "Fog::OpenStack::Compute | Compute aggregate requests" do
  before do
    @aggregate_format = {
      "availability_zone" => Fog::Nullable::String,
      "created_at"        => String,
      "deleted"           => Fog::Boolean,
      "deleted_at"        => Fog::Nullable::String,
      "id"                => Integer,
      "name"              => String,
      "updated_at"        => Fog::Nullable::String
    }

    @detailed_aggregate_format = @aggregate_format.merge('hosts' => Array)
    @metadata_aggregate_format = @aggregate_format.merge("metadata" => Hash)
    @compute = Fog::OpenStack::Compute.new

    @aggregate_body = @compute.create_aggregate('test_aggregate').body
    @aggregate = @aggregate_body['aggregate']
  end

  describe "success" do
    it "#create_aggregate" do
      @aggregate_body.must_match_schema('aggregate' => @aggregate_format)
    end

    it "#list_aggregates" do
      @compute.list_aggregates.body.
        must_match_schema('aggregates' => [@metadata_aggregate_format])
    end

    it "#update_aggregate" do
      @aggregate_attributes = {'name' => 'test_aggregate2'}
      @compute.update_aggregate(@aggregate['id'], @aggregate_attributes).body.
        must_match_schema('aggregate' => @aggregate_format)
    end

    it "#get_aggregate" do
      @compute.get_aggregate(@aggregate['id']).body.
        must_match_schema('aggregate' => @detailed_aggregate_format)
    end

    describe "with aggregate host" do
      let(:host_name) do
        @compute.hosts.select { |x| x.service_name == 'compute' }.first.host_name
      end

      it "#add_aggregate_host" do
        @compute.add_aggregate_host(@aggregate['id'], host_name).status.must_equal 200
      end

      it "#remove_aggregate_host" do
        @compute.remove_aggregate_host(@aggregate['id'], host_name).status.must_equal 200
      end
    end

    it "#update_aggregate_metadata" do
      @compute.update_aggregate_metadata(@aggregate['id'], 'test' => 'test', 'test2' => 'test2').status.must_equal 200
    end

    it "#delete_aggregate" do
      @compute.delete_aggregate(@aggregate['id']).status.must_equal 200
    end
  end
end
