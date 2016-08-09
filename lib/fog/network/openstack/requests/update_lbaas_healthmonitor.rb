module Fog
  module Network
    class OpenStack
      class Real
        def update_lbaas_healthmonitor(healthmonitor_id, options = {})
          data = {'healthmonitor' => {}}

          vanilla_options = [:name, :delay, :timeout, :max_retries, :http_method, :url_path, :expected_codes, :admin_state_up]
          vanilla_options.select { |o| options.key?(o) }.each do |key|
            data['healthmonitor'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => 200,
            :method  => 'PUT',
            :path    => "lbaas/healthmonitors/#{healthmonitor_id}"
          )
        end
      end

      class Mock
        def update_lbaas_healthmonitor(healthmonitor_id, options = {})
          {
              "healthmonitor": {
                  "admin_state_up": true,
                  "delay": 7,
                  "expected_codes": "200",
                  "http_method": "GET",
                  "id": "ccf0ff20-7027-445d-88a5-9ff4806ab0b4",
                  "max_retries": 7,
                  "name": "hasenhealth",
                  "pools": [
                      {
                          "id": "e0fabc88-7e9f-4402-848a-8b339e003f89"
                      }
                  ],
                  "tenant_id": "f2f13e79a68b441ebe99c8272a7ccd27",
                  "timeout": 7,
                  "type": "PING",
                  "url_path": "/"
              }
          }
          response = Excon::Response.new
          if healthmonitor = list_lb_health_monitors.body['healthmonitors'].find { |_| _['id'] == healthmonitor_id }
            healthmonitor['delay']          = options[:delay]
            healthmonitor['timeout']        = options[:timeout]
            healthmonitor['max_retries']    = options[:max_retries]
            healthmonitor['http_method']    = options[:http_method]
            healthmonitor['url_path']       = options[:url_path]
            healthmonitor['expected_codes'] = options[:expected_codes]
            healthmonitor['admin_state_up'] = options[:admin_state_up]
            response.body = {'healthmonitor' => healthmonitor}
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
