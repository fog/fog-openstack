require 'spec_helper'

describe Fog::OpenStack::Image do
  it "Upload/download image data using chunked IO" do
    # We only run this against a live system,
    # because VCR's use of Webmock stops Excon :response_block from working correctly
    if ENV['OS_AUTH_URL']

      @os_auth_url = ENV['OS_AUTH_URL']

      # allow us to ignore dev certificates on servers
      Excon.defaults[:ssl_verify_peer] = false if ENV['SSL_VERIFY_PEER'] == 'false'

      # setup the service object
      @service ||= Fog::OpenStack::Image.new(
        :openstack_auth_url     => "#{@os_auth_url}/auth/tokens",
        :openstack_project_name => ENV.fetch('OS_PROJECT_NAME'),
        :openstack_username     => ENV.fetch('OS_USERNAME'),
        :openstack_api_key      => ENV.fetch('OS_PASSWORD'),
        :openstack_region       => ENV['OS_REGION_NAME'] || 'RegionOne',
        :openstack_domain_name  => ENV['OS_USER_DOMAIN_NAME'] || 'Default'
      )

      spec_data_folder = 'spec/fixtures/openstack/image_v2'

      begin
        ####
        ## Upload & download data using request/response blocks so we can stream data effectively
        ####
        # "no-op" virtual machine image, 80kB .ova file containing 64Mb dynamic disk
        image_path = "#{spec_data_folder}/minimal.ova"

        foobar_image = @service.images.create(:name             => 'foobar_up2',
                                              :container_format => 'ovf',
                                              :disk_format      => 'vmdk')
        foobar_id = foobar_image.id

        data_file = File.new(image_path, 'r')
        chunker = lambda do
          # Excon.defaults[:chunk_size] defaults to 1048576, ie 1MB
          # to_s will convert the nil received after everything is read to the final empty chunk
          data_file.read(Excon.defaults[:chunk_size]).to_s
        end
        foobar_image.upload_data(:request_block => chunker)

        # Make sure the upload is finished
        while @service.images.find_by_id(foobar_id).status == 'saving'
          sleep 1
        end
        @service.images.find_by_id(foobar_id).status.must_equal 'active'

        size = 0
        read_block = lambda do |chunk, _remaining, _total|
          size += chunk.size
        end
        foobar_image.download_data(:response_block => read_block)
        size.must_equal File.size(image_path)
      ensure
        # Delete the image
        foobar_image.destroy if foobar_image

        @service.images.all(:name => 'foobar_up2').each(&:destroy)

        # Check that the deletion worked
        if foobar_id
          proc do
            @service.images.find_by_id foobar_id
          end.must_raise Fog::OpenStack::Image::NotFound
        end
        @service.images.all(:name => 'foobar_up2').length.must_equal 0
      end
    end
  end
end
