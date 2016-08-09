module Fog
  module Network
    class OpenStack
      class Real
        def get_lbaas_listener(listener_id)
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "lbaas/listners/#{listener_id}"
          )
        end
      end

      class Mock
        def get_lbaas_listener(listener_id)
          {
              "listener": {
                  "admin_state_up": true,
                  "connection_limit": -1,
                  "default_pool_id": null,
                  "default_tls_container_ref": null,
                  "description": "",
                  "id": "a824b9dc-5c61-4610-a68f-ff9cbd49facb",
                  "loadbalancers": [
                      {
                          "id": "70286877-bceb-4aab-a3db-b14bf11c8d3c"
                      }
                  ],
                  "name": "",
                  "protocol": "HTTP",
                  "protocol_port": 90,
                  "sni_container_refs": [],
                  "tenant_id": "f2f13e79a68b441ebe99c8272a7ccd27"
              }
          }
          response = Excon::Response.new
          if data = self.data[:lbaas_listeners][listener_id]
            response.status = 200
            response.body = {'listener' => data}
            response
          else
            raise Fog::Network::OpenStack::NotFound
          end
        end
      end
    end
  end
end
