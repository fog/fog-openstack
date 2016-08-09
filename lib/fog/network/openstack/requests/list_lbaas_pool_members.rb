module Fog
  module Network
    class OpenStack
      class Real
        def list_lbaas_pool_members(pool_id, filters = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => "lbaas/pools/#{pool_id}/members",
            :query   => filters
          )
        end
      end

      class Mock
        def list_lbaas_pool_members(pool_id, _filters = {})
          {
              "members": [
                  {
                      "address": "10.0.0.244",
                      "admin_state_up": true,
                      "id": "e9e42f7b-42e3-48b0-8f85-dbf1e8ba358e",
                      "name": "",
                      "protocol_port": 9000,
                      "subnet_id": "6f6282ba-bae1-46af-8575-d8bacdbc0e32",
                      "tenant_id": "f2f13e79a68b441ebe99c8272a7ccd27",
                      "weight": 1
                  }
              ]
          }
          Excon::Response.new(
            :body   => {'members' => data[:lb_members].values},
            :status => 200
          )
        end
      end
    end
  end
end
