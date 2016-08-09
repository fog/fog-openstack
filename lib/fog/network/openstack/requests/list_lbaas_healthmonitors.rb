module Fog
  module Network
    class OpenStack
      class Real
        def list_lbaas_healthmonitors(filters = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => 'lbaas/healthmonitors',
            :query   => filters
          )
        end
      end

      class Mock
        def list_lbaas_healthmonitors(_filters = {})
          {
              "healthmonitors": [
                  {
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
              ]
          }
          Excon::Response.new(
            :body   => {'healthmonitors' => data[:lbaas_healthmonitors].values},
            :status => 200
          )
        end
      end
    end
  end
end
