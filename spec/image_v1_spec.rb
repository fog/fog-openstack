require 'spec_helper'
require_relative './shared_context'

describe Fog::Image::OpenStack do
  before :all do
    openstack_vcr = OpenStackVCR.new(
      :vcr_directory => 'spec/fixtures/openstack/image_v1',
      :service_class => Fog::Image::OpenStack::V1
    )
    @service = openstack_vcr.service
  end

  it 'lists available images' do
    VCR.use_cassette('list_images') do
      @images = @service.images.all
    end
  end
end
