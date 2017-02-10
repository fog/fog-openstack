module Fog
  module DNS
    class OpenStack
      class V2
        class Real
          def create_zone_transfer_accept(key, zone_transfer_request_id)
            data = {
              :key => key,
              :zone_transfer_request_id => zone_transfer_request_id
            }

            request(
              :body    => Fog::JSON.encode(data),
              :expects => 200,
              :method  => 'POST',
              :path    => "zones/tasks/transfer_accepts"
            )
          end
        end

        class Mock
          def create_zone_transfer_accept(key, zone_transfer_request_id)
            response = Excon::Response.new
            response.status = 200
            response.body = data[:zone_transfer_accepts]["transfer_accepts"].first
            response
          end
        end
      end
    end
  end
end
