module Fog
  module Network
    class OpenStack
      class Real
        def get_lbaas_healthmonitor(healthmonitor_id)
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "lbaas/healthmonitors/#{healthmonitor_id}"
          )
        end
      end

      class Mock
        def get_lbaas_healthmonitor(healthmonitor_id)
          {
              "healthmonitor": {
                  "admin_state_up": true,
                  "delay": 3,
                  "expected_codes": "200",
                  "http_method": "GET",
                  "id": "ccf0ff20-7027-445d-88a5-9ff4806ab0b4",
                  "max_retries": 5,
                  "name": "",
                  "pools": [
                      {
                          "id": "e0fabc88-7e9f-4402-848a-8b339e003f89"
                      }
                  ],
                  "tenant_id": "f2f13e79a68b441ebe99c8272a7ccd27",
                  "timeout": 9,
                  "type": "PING",
                  "url_path": "/"
              }
          }
          response = Excon::Response.new
          if data = self.data[:lbaas_healthmonitors][healthmonitor_id]
            response.status = 200
            response.body = {'healthmonitor' => data}
            response
          else
            raise Fog::Network::OpenStack::NotFound
          end
        end
      end
    end
  end
end
