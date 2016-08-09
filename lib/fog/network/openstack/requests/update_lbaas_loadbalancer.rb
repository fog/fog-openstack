module Fog
  module Network
    class OpenStack
      class Real
        def update_lbaas_loadbalancer(loadbalancer_id, options = {})
          data = {
              'loadbalancer' => {}
          }

          vanilla_options = [:name, :description, :admin_state_up]
          vanilla_options.select { |o| options.key?(o) }.each do |key|
            data['loadbalancer'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => 200,
            :method  => 'PUT',
            :path    => "lbaas/loadbalancers/#{loadbalancer_id}"
          )
        end
      end

      class Mock
        def update_lbaas_loadbalancer(loadbalancer_id, options = {})
          {
              "loadbalancer": {
                  "admin_state_up": true,
                  "description": "",
                  "id": "70286877-bceb-4aab-a3db-b14bf11c8d3c",
                  "listeners": [],
                  "name": "hase",
                  "operating_status": "OFFLINE",
                  "provider": "f5networks",
                  "provisioning_status": "PENDING_UPDATE",
                  "tenant_id": "f2f13e79a68b441ebe99c8272a7ccd27",
                  "vip_address": "10.0.0.245",
                  "vip_port_id": "dfbfafcd-095e-44f2-bdd3-4af66b50d2b1",
                  "vip_subnet_id": "6f6282ba-bae1-46af-8575-d8bacdbc0e32"
              }
          }
          response = Excon::Response.new
          if loadbalancer = list_lbaas_loadbalancers.body['loadbalancers'].find { |_| _['id'] == loadbalancer_id }
            loadbalancer['name']                = options[:name]
            loadbalancer['description']         = options[:description]
            loadbalancer['admin_state_up']      = options[:admin_state_up]
            response.body = {'loadbalancer' => loadbalancer}
            response.status = 200
            response
          else
            raise Fog::Network::OpenStack::NotFound
          end
        end
      end
    end
  end
end
