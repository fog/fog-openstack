module Fog
  module Network
    class OpenStack
      class Real
        def create_lbaas_healthmonitor(pool_id, type, delay, timeout, max_retries, options = {})
          data = {
            'healthmonitor' => {
              'pool_id'     => pool_id,
              'type'        => type,
              'delay'       => delay,
              'timeout'     => timeout,
              'max_retries' => max_retries
            }
          }

          vanilla_options = [:http_method, :url_path, :expected_codes, :admin_state_up, :tenant_id]
          vanilla_options.reject { |o| options[o].nil? }.each do |key|
            data['healthmonitor'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [201],
            :method  => 'POST',
            :path    => 'lbaas/healthmonitors'
          )
        end
      end

      class Mock
        def create_lbaas_healthmonitor(type, delay, timeout, max_retries, options = {})
          {
              "healthmonitor": {
                  "admin_state_up": true,
                  "delay": 3,
                  "expected_codes": "200",
                  "http_method": "GET",
                  "id": "ccf0ff20-7027-445d-88a5-9ff4806ab0b4",
                  "max_retries": 5,
                  "name": "",
                  "pools": [
                      {
                          "id": "e0fabc88-7e9f-4402-848a-8b339e003f89"
                      }
                  ],
                  "tenant_id": "f2f13e79a68b441ebe99c8272a7ccd27",
                  "timeout": 9,
                  "type": "PING",
                  "url_path": "/"
              }
          }
          response = Excon::Response.new
          response.status = 201
          data = {
            'id'             => Fog::Mock.random_numbers(6).to_s,
            'type'           => type,
            'delay'          => delay,
            'timeout'        => timeout,
            'max_retries'    => max_retries,
            'http_method'    => options[:http_method],
            'url_path'       => options[:url_path],
            'expected_codes' => options[:expected_codes],
            'status'         => 'ACTIVE',
            'admin_state_up' => options[:admin_state_up],
            'tenant_id'      => options[:tenant_id],
          }

          self.data[:lb_health_monitors][data['id']] = data
          response.body = {'healthmonitor' => data}
          response
        end
      end
    end
  end
end
