module Fog
  module Network
    class OpenStack
      class Real
        def update_lbaas_pool(pool_id, options = {})
          data = {'pool' => {}}

          vanilla_options = [:name, :description, :lb_method, :admin_state_up]
          vanilla_options.select { |o| options.key?(o) }.each do |key|
            data['pool'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => 200,
            :method  => 'PUT',
            :path    => "lb/pools/#{pool_id}"
          )
        end
      end

      class Mock
        def update_lbaas_pool(pool_id, options = {})
          {
              "pool": {
                  "admin_state_up": true,
                  "description": "",
                  "healthmonitor_id": null,
                  "id": "e0fabc88-7e9f-4402-848a-8b339e003f89",
                  "lb_algorithm": "SOURCE_IP",
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
          if pool = list_lb_pools.body['pools'].find { |_| _['id'] == pool_id }
            pool['name']            = options[:name]
            pool['description']     = options[:description]
            pool['lb_method']       = options[:lb_method]
            pool['admin_state_up']  = options[:admin_state_up]
            response.body = {'pool' => pool}
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
