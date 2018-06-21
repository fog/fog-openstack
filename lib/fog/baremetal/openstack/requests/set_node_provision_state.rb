module Fog
  module Baremetal
    class OpenStack
      class Real
        def set_node_provision_state(node_id, provision_state)
          data = {
            'target' => provision_state
          }

          request(
            :body    => Fog::JSON.encode(data),
            :expects => 202,
            :method  => 'PUT',
            :path    => "nodes/#{node_id}/states/provision",
            :headers => {
              :'X-OpenStack-Ironic-API-Version' => 'latest'
            }
          )
        end
      end

      class Mock
        def set_node_provision_state(_node_id, _provision_state)
          response = Excon::Response.new
          response.status = 202
          response.headers = {
            "X-Compute-Request-Id" => "req-fdc6f99e-55a2-4ab1-8904-0892753828cf",
            "Content-Type"         => "application/json",
            "Content-Length"       => "356",
            "Date"                 => Date.new
          }
          response.body = data[:nodes].first
          response
        end
      end
    end
  end
end
