module Fog
  module SharedFileSystem
    class OpenStack
      class Real
        def list_share_export_locations(share_id)
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => "shares/#{share_id}/export_locations"
          )
        end
      end

      class Mock
        def list_share_export_locations(share_id)
          response = Excon::Response.new
          response.status = 200

          locations = data[:export_locations]
          locations.each do |location|
            location[:share_instance_id] = share_id
          end

          response.body = {'export_locations' => locations}
          response
        end
      end
    end
  end
end
