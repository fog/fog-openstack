module Fog
  module Network
    class OpenStack
      class Real
        def list_lbaas_loadbalancers(filters = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => 'lbaas/loadbalancers',
            :query   => filters
          )
        end
      end

      class Mock
        def list_lbaas_loadbalancers(_filters = {})
          {
              "loadbalancers": [
                  {
                      "admin_state_up": true,
                      "description": "",
                      "id": "70286877-bceb-4aab-a3db-b14bf11c8d3c",
                      "listeners": [],
                      "name": "",
                      "operating_status": "OFFLINE",
                      "provider": "f5networks",
                      "provisioning_status": "ERROR",
                      "tenant_id": "f2f13e79a68b441ebe99c8272a7ccd27",
                      "vip_address": "10.0.0.245",
                      "vip_port_id": "dfbfafcd-095e-44f2-bdd3-4af66b50d2b1",
                      "vip_subnet_id": "6f6282ba-bae1-46af-8575-d8bacdbc0e32"
                  }
              ]
          }
          Excon::Response.new(
            :body   => {'loadbalancers' => [data[:lbaas_loadbalancer]]},
            :status => 200
          )
        end
      end
    end
  end
end
