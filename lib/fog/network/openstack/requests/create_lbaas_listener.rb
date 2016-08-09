module Fog
  module Network
    class OpenStack
      class Real
        def create_lbaas_listener(loadbalancer_id, protocol, protocol_port, options = {})
          data = {
            'listener' => {
              'loadbalancer_id' => loadbalancer_id,
              'protocol'        => protocol,
              'protocol_port'   => protocol_port
            }
          }

          vanilla_options = [:name, :description, :default_pool_id, :connection_limit, :default_tls_container_ref, :sni_container_refs,
                             :admin_state_up, :tenant_id]
          vanilla_options.reject { |o| options[o].nil? }.each do |key|
            data['listener'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [201],
            :method  => 'POST',
            :path    => 'lbaas/listeners'
          )
        end
      end

      class Mock
        def create_lb_vip(loadbalancer_id, protocol, protocol_port, options = {})
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
          response.status = 201
          data = {
            'id'                      => Fog::Mock.random_numbers(6).to_s,
            'loadbalancer_id'         => loadbalancer_id,
            'protocol'                => protocol,
            'protocol_port'           => protocol_port,
            'name'                    => options[:name],
            'description'             => options[:description],
            'default_pool_id'         => options[:default_pool_id],
            'connection_limit'        => options[:connection_limit],
            'default_tls_container_ref' => options[:default_tls_container_ref],
            'sni_container_refs'      => options[:sni_container_refs],
            'admin_state_up'          => options[:admin_state_up],
            'tenant_id'               => options[:tenant_id],
            'loadbalancers'           => []
          }

          self.data[:lbaas_listener][data['id']] = data
          response.body = {'listener' => data}
          response
        end
      end
    end
  end
end
