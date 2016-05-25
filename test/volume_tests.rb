require 'test_helper'

require 'fog/openstack/volume'
require 'fog/openstack/volume_v1'
require 'fog/openstack/volume_v2'

describe "Fog::Volume[:openstack], ['openstack', 'volume']" do
  volume = Fog::Volume[:openstack]

  describe "Volumes collection" do
    %w{ volumes }.each do |collection|
      it "should respond to #{collection}" do
        volume.respond_to? collection
      end

      it "should respond to #{collection}.all" do
        eval("volume.#{collection}").respond_to? 'all'
      end

      # not implemented
      # it "should respond to #{collection}.get" do
      #   eval("volume.#{collection}").respond_to? 'get'
      # end
    end
  end
end
