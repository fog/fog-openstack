module Fog
  module Compute
    class OpenStack
      class Real
        def delete_server_group(group_id)
          rsp = request(
            :expects  => 204,
            :method   => 'DELETE',
            :path     => "os-server-groups/#{group_id}"
          )
        end
      end

      class Mock
        def delete_server_group(group_id)
          response = Excon::Response.new
          response.status = 204
          response.headers = {
            "Content-Type" => "text/html; charset=UTF-8",
            "Content-Length" => "0",
            "Date" => Date.new
          }
          response
        end
      end
    end
  end
end
