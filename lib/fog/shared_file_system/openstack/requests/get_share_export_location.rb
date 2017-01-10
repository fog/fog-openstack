module Fog
  module SharedFileSystem
    class OpenStack
      class Real
        def get_share_export_location(share_id,export_location_id)
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => "shares/#{share_id}/export_locations/​{export_location_id}​"
          )
        end
      end

      class Mock
        def get_share_export_location(id)
          response = Excon::Response.new
          response.status = 200
          share_export_location = data[:share_export_location]
          share_export_location['id'] = id
          response.body = share_export_location
          response
        end
      end
    end
  end
end
