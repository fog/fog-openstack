require "test_helper"

require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

describe "Fog::OpenStack::Compute | image requests" do
  before do
    @image_format = {
      'created'  => Fog::Nullable::String,
      'id'       => String,
      'name'     => String,
      'progress' => Fog::Nullable::Integer,
      'status'   => String,
      'updated'  => String,
      'minRam'   => Integer,
      'minDisk'  => Integer,
      'server'   => Fog::Nullable::Hash,
      'metadata' => Hash,
      'links'    => Array
    }

    @compute = Fog::OpenStack::Compute.new
  end

  describe "success" do
    before do
      @image_id = Fog::OpenStack::Compute.new.images[0].id
      unless Fog.mocking?
        @compute.images.get(@image_id).wait_for { ready? }
      end
    end

    it "#get_image_details(#{@image_id})" do
      unless Fog.mocking?
        @compute.get_image_details(@image_id).body['image'].
          must_match_schema(@image_format)
      end
    end

    it "#list_images" do
      @compute.list_images.body.
        must_match_schema('images' => [OpenStack::Compute::Formats::SUMMARY])
    end

    it "#list_images_detail" do
      @compute.list_images_detail.body.
        must_match_schema('images' => [@image_format])
    end

    after do
      unless Fog.mocking?
        @compute.images.get(@image_id).wait_for { ready? }
      end
    end
  end

  describe "failure" do
    it "#delete_image(0)" do
      unless Fog.mocking?
        proc do
          @compute.delete_image(0)
        end.must_raise Fog::OpenStack::Compute::NotFound
      end
    end

    it "#get_image_details(0)" do
      unless Fog.mocking?
        proc do
          @compute.get_image_details(0)
        end.must_raise Fog::OpenStack::Compute::NotFound
      end
    end
  end
end
