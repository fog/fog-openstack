module Fog
  module Network
    class OpenStack
      class Real
        def list_lbaas_pools(filters = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => 'lbaas/pools',
            :query   => filters
          )
        end
      end

      class Mock
        def list_lbaas_pools(_filters = {})
          {
              "pools": [
                  {
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
              ]
          }
          Excon::Response.new(
            :body   => {'pools' => data[:lb_pools].values},
            :status => 200
          )
        end
      end
    end
  end
end
