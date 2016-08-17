module Fog
  module DNS
    class OpenStack
      class V2
        class Real
          def list_recordsets(zone_id, options = {})
            request(
              :expects => 200,
              :method  => 'GET',
              :path    => "zones/#{zone_id}/recordsets",
              :query   => options
            )
          end
        end

        class Mock
          def list_recordsets(zone_id, _options = {})
            response = Excon::Response.new
            response.status = 200
            response.body = data[:recordsets]["recordsets"].merge("zone_id" => zone_id)
            response
          end
        end
      end
    end
  end
end
