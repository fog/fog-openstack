module Fog
  module Network
    class OpenStack
      class Real
        def update_lbaas_listener(listener_id, options = {})
          data = {
              'listener' => {}
          }

          vanilla_options = [:name, :description, :connection_limit, :default_tls_container_ref, :sni_container_refs,
                             :admin_state_up]
          vanilla_options.reject { |o| options[o].nil? }.each do |key|
            data['listener'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => 200,
            :method  => 'PUT',
            :path    => "lbaas/listeners/#{listener_id}"
          )
        end
      end

      class Mock
        def update_lbaas_listener(listener_id, options = {})
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
                  "name": "list-hase",
                  "protocol": "HTTP",
                  "protocol_port": 90,
                  "sni_container_refs": [],
                  "tenant_id": "f2f13e79a68b441ebe99c8272a7ccd27"
              }
          }
          response = Excon::Response.new
          if listener = list_lbaas_listeners.body['listeners'].find { |_| _['id'] == listener_id }
            listener['name']                = options[:name]
            listener['description']         = options[:description]
            listener['connection_limit'] = options[:connection_limit]
            listener['default_tls_container_ref']    = options[:default_tls_container_ref]
            listener['sni_container_refs']    = options[:sni_container_refs]
            listener['admin_state_up']      = options[:admin_state_up]
            response.body = {'listener' => listener}
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
