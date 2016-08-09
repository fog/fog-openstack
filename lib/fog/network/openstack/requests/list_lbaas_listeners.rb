module Fog
  module Network
    class OpenStack
      class Real
        def list_lbaas_listeners(filters = {})
          request(
              :expects => 200,
              :method => 'GET',
              :path => 'lbaas/listeners',
              :query => filters
          )
        end
      end

      class Mock
        def list_lbaas_listeners(_filters = {})
          {
              "listeners": [
                  {
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
                  },
                  {
                      "admin_state_up": true,
                      "connection_limit": -1,
                      "default_pool_id": null,
                      "default_tls_container_ref": null,
                      "description": "",
                      "id": "6693e708-5a26-4350-9e17-ea30e60af22c",
                      "loadbalancers": [
                          {
                              "id": "70286877-bceb-4aab-a3db-b14bf11c8d3c"
                          }
                      ],
                      "name": "",
                      "protocol": "HTTP",
                      "protocol_port": 89,
                      "sni_container_refs": [],
                      "tenant_id": "f2f13e79a68b441ebe99c8272a7ccd27"
                  }
              ]
          }

          Excon::Response.new(
              :body => {'listeners' => data[:lbaas_listeners].values},
              :status => 200
          )
        end
      end
    end
  end
end
