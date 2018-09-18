require "test_helper"

describe "Fog::OpenStack::Compute | volume requests" do
  before do
    @volume_format = {
      'id'                 => String,
      'displayName'        => String,
      'size'               => Integer,
      'displayDescription' => String,
      'status'             => String,
      'snapshotId'         => Fog::Nullable::String,
      'availabilityZone'   => String,
      'attachments'        => Array,
      'volumeType'         => Fog::Nullable::String,
      'createdAt'          => String,
      'metadata'           => Hash
    }

    @compute = Fog::OpenStack::Compute.new
    @volume = @compute.create_volume('loud', 'this is a loud volume', 3).body
  end

  describe "success" do
    it "#create_volume" do
      @volume.must_match_schema('volume' => @volume_format)
    end

    it "#list_volumes" do
      @compute.list_volumes.body.must_match_schema('volumes' => [@volume_format])
    end

    describe "body" do
      before do
        @volume_id = @compute.volumes.all.first.id
      end

      it "#get_volume_detail" do
        @compute.get_volume_details(@volume_id).
          body.must_match_schema('volume' => @volume_format)
      end

      it "delete_volume" do
        @compute.delete_volume(@volume_id).status.must_equal 204
      end
    end
  end
end
