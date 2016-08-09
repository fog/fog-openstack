module Fog
  module Network
    class OpenStack
      class Real
        def create_lbaas_loadbalancer(vip_subnet_id, options = {})
          data = {
              'loadbalancer' => {
                  'vip_subnet_id' => vip_subnet_id
              }
          }
          vanilla_options = [:name, :description, :vip_address, :provider, :flavor, :admin_state_up, :tenant_id]
          vanilla_options.reject { |o| options[o].nil? }.each do |key|
            data['loadbalancer'][key] = options[key]
          end

          request(
              :body => Fog::JSON.encode(data),
              :expects => [201],
              :method => 'POST',
              :path => 'lbaas/loadbalancers'
          )
        end
      end

      class Mock
        def create_lbaas_loadbalancer(vip_subnet_id, options = {})
          {
              "loadbalancer": {
                  "admin_state_up": true,
                  "description": "",
                  "id": "70286877-bceb-4aab-a3db-b14bf11c8d3c",
                  "listeners": [],
                  "name": "",
                  "operating_status": "OFFLINE",
                  "provider": "f5networks",
                  "provisioning_status": "PENDING_CREATE",
                  "tenant_id": "f2f13e79a68b441ebe99c8272a7ccd27",
                  "vip_address": "10.0.0.245",
                  "vip_port_id": "dfbfafcd-095e-44f2-bdd3-4af66b50d2b1",
                  "vip_subnet_id": "6f6282ba-bae1-46af-8575-d8bacdbc0e32"
              }
          }
          response = Excon::Response.new
          response.status = 201
          data = {
              'id' => Fog::Mock.random_numbers(6).to_s,
              'subnet_id' => vip_subnet_id,
              'name' => options[:name],
              'description' => options[:description],
              'vip_address' => options[:vip_address],
              'flavor' => options[:flavor],
              'admin_state_up' => options[:admin_state_up],
              'tenant_id' => options[:tenant_id],
              "listeners": [],
              "operating_status": "OFFLINE",
              "provider": "f5networks",
              "provisioning_status": "PENDING_CREATE",
              "vip_address": "10.0.0.245",
              "vip_port_id": "dfbfafcd-095e-44f2-bdd3-4af66b50d2b1",
              "vip_subnet_id": "6f6282ba-bae1-46af-8575-d8bacdbc0e32"
          }
          self.data[:lbaas_loadbalancer][data['id']] = data
          response.body = {'loadbalancer' => data}
          response
        end
      end
    end
  end
end
