module Fog
  module DNS
    class OpenStack
      class V2
        class Real
          def get_zone(id)
            request(
              :expects => 200,
              :method  => 'GET',
              :path    => "zones/#{id}"
            )
          end
        end

        class Mock
          def get_zone(id)
            response = Excon::Response.new
            response.status = 200
            zone = data[:zone_updated] || data[:zones].first
            zone["id"] = id
            response.body = zone
            response
          end
        end
      end
    end
  end
end
