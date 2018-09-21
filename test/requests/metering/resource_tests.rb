require "test_helper"

describe "Fog::Metering[:openstack] | resource requests" do
  before do
    @metering = Fog::Metering[:openstack]

    @resource_format = {
      'resource_id' => String,
      'project_id'  => String,
      'user_id'     => String,
      'metadata'    => Hash
    }
  end

  describe "success" do
    it "#list_resource" do
      @metering.list_resources.body.must_match_schema([@resource_format])
    end

    it "#get_resource" do
      @metering.get_resource('test').body.must_match_schema(@resource_format)
    end
  end
end
