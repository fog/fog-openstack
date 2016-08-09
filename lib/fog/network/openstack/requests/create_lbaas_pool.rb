module Fog
  module Network
    class OpenStack
      class Real
        def create_lbaas_pool(listener_id, protocol, lb_algorithm, options = {})
          data = {
            'pool' => {
              'listener_id' => listener_id,
              'protocol'  => protocol,
              'lb_algorithm' => lb_algorithm
            }
          }

          vanilla_options = [:name, :description, :admin_state_up, :tenant_id, :session_persistence]
          vanilla_options.reject { |o| options[o].nil? }.each do |key|
            data['pool'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [201],
            :method  => 'POST',
            :path    => 'lbaas/pools'
          )
        end
      end

      class Mock
        def create_lbaas_pool(subnet_id, protocol, lb_method, options = {})
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
          response.status = 201
          data = {
            'id'                 => Fog::Mock.random_numbers(6).to_s,
            'subnet_id'          => subnet_id,
            'protocol'           => protocol,
            'lb_method'          => lb_method,
            'name'               => options[:name],
            'description'        => options[:description],
            'health_monitors'    => [],
            'members'            => [],
            'status'             => 'ACTIVE',
            'admin_state_up'     => options[:admin_state_up],
            'vip_id'             => nil,
            'tenant_id'          => options[:tenant_id],
            'active_connections' => nil,
            'bytes_in'           => nil,
            'bytes_out'          => nil,
            'total_connections'  => nil
          }

          self.data[:lb_pools][data['id']] = data
          response.body = {'pool' => data}
          response
        end
      end
    end
  end
end
