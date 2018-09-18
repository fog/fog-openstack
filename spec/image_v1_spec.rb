require 'spec_helper'
require_relative './shared_context'

describe Fog::OpenStack::Image do
  before :all do
    openstack_vcr = OpenStackVCR.new(
      :vcr_directory => 'spec/fixtures/openstack/image_v1',
      :service_class => Fog::OpenStack::Image::V1
    )
    @service = openstack_vcr.service
  end

  it 'lists available images' do
    VCR.use_cassette('list_images') do
      @images = @service.images.all
    end
  end

  describe 'find_by_id' do
    it 'finds image' do
      existing_image_id = 'ea20c966-d2fb-4287-a2eb-7bece9af4263'
      VCR.use_cassette('images_v1_find_by_id') do
        @service.images.find_by_id(existing_image_id).id.must_equal existing_image_id
      end
    end

    it 'returns nil when image is not found' do
      VCR.use_cassette('images_v1_find_by_id') do
        assert_nil @service.images.find_by_id('non-existing-id')
      end
    end

    it 'returns custom properties' do
      existing_image_id = 'ea20c966-d2fb-4287-a2eb-7bece9af4263'
      expected_value = 'bar'
      VCR.use_cassette('images_v1_find_by_id') do
        @service.images.find_by_id(existing_image_id).properties['foo'].must_equal expected_value
      end
    end
  end
end
