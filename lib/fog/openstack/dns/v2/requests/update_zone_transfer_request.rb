module Fog
  module OpenStack
    class DNS
      class V2
        class Real
          def update_zone_transfer_request(zone_transfer_request_id, _description, options = {})
            vanilla_options = [:target_project_id]
            data = vanilla_options.each_with_object({}) do |option, result|
              result[option] = options[option] if options[option]
            end

            request(
              expects: 200,
              method: 'PATCH',
              path: "zones/tasks/transfer_requests/#{zone_transfer_request_id}",
              body: Fog::JSON.encode(data)
            )
          end
        end

        class Mock
          def update_zone_transfer_request(zone_transfer_request_id, description, _options = {})
            response = Excon::Response.new
            response.status = 200
            request = data[:zone_transfer_requests]["transfer_requests"]
            request.id = zone_transfer_request_id
            request.description = description
            response.body = request
            response
          end
        end
      end
    end
  end
end
