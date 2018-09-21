require 'test_helper'

describe "Fog::OpenStack::Volume | volume_type requests" do
  before do
    @volume = Fog::OpenStack::Volume.new

    @volume_type_format = {
      'name'        => String,
      'extra_specs' => Hash,
      'id'          => String
    }

    @volume_type = @volume.create_volume_type(:name => 'test_volume_type').body['volume_type']
  end

  describe "success" do
    it "#create_volume_type" do
      @volume_type.must_match_schema(@volume_type_format)
    end

    it "#update_volume_type" do
      @volume.update_volume_type(
        @volume_type['id'],
        :name => 'test_volume_type_1'
      ).body['volume_type'].must_match_schema(@volume_type_format)
    end

    it "#get_volume_type" do
      @volume.get_volume_type_details(@volume_type['id']).body['volume_type'].
        must_match_schema(@volume_type_format)
    end

    it "#list_volume_type" do
      @volume.list_volume_types.body['volume_types'].
        must_match_schema([@volume_type_format])
    end

    it 'delete the volute type' do
      @volume.delete_volume_type(@volume_type['id'])
    end
  end
end
