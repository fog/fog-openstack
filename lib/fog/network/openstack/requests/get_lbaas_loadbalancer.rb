module Fog
  module Network
    class OpenStack
      class Real
        def get_lbaas_loadbalancer(loadbalancer_id)
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "lbaas/loadbalancers/#{loadbalancer_id}"
          )
        end
      end

      class Mock
        def get_lbaas_loadbalancer(loadbalancer_id)
          {
              "loadbalancer": {
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
          }
          response = Excon::Response.new
          if data = self.data[:lbaas_loadbalancer][loadbalancer_id]
            response.status = 200
            response.body = {'loadbalancer' => data[:lbaas_loadbalancer]}
            response
          else
            raise Fog::Network::OpenStack::NotFound
          end
        end
      end
    end
  end
end
