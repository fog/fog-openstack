require 'fog/openstack/volume/requests/create_volume'

module Fog
  module OpenStack
    class Volume
      class V1
        class Real
          def create_volume(name, description, size, options = {})
            data = {
              'volume' => {
                'display_name'        => name,
                'display_description' => description,
                'size'                => size
              }
            }

            _create_volume(data, options)
          end

          include Fog::OpenStack::Volume::Real
        end

        class Mock
          def create_volume(name, description, size, options = {})
            response        = Excon::Response.new
            response.status = 202
            response.body   = {
              'volume' => {
                'id'                  => Fog::Mock.random_numbers(2),
                'display_name'        => name,
                'display_description' => description,
                'metadata'            => options['metadata'] || {},
                'size'                => size,
                'status'              => 'creating',
                'snapshot_id'         => options[:snapshot_id] || nil,
                'image_id'            => options[:imageRef] || nil,
                'volume_type'         => nil,
                'availability_zone'   => 'nova',
                'created_at'          => Time.now,
                'attachments'         => []
              }
            }
            response
          end
        end
      end
    end
  end
end
