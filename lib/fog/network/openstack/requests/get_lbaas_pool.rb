module Fog
  module Network
    class OpenStack
      class Real
        def get_lbaas_pool(pool_id)
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "lbaas/pools/#{pool_id}"
          )
        end
      end

      class Mock
        def get_lbaas_pool(pool_id)
          {
              "pool": {
                  "admin_state_up": true,
                  "description": "",
                  "healthmonitor_id": null,
                  "id": "e0fabc88-7e9f-4402-848a-8b339e003f89",
                  "lb_algorithm": "ROUND_ROBIN",
                  "listeners": [
                      {
                          "id": "a824b9dc-5c61-4610-a68f-ff9cbd49facb"
                      }
                  ],
                  "members": [],
                  "name": "",
                  "protocol": "HTTP",
                  "session_persistence": null,
                  "tenant_id": "f2f13e79a68b441ebe99c8272a7ccd27"
              }
          }
          response = Excon::Response.new
          if data = self.data[:lb_pools][pool_id]
            response.status = 200
            response.body = {'pool' => data}
            response
          else
            raise Fog::Network::OpenStack::NotFound
          end
        end
      end
    end
  end
end
