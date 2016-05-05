module Fog
  module Compute
    class OpenStack
      class Real
        def evacuate_server(server_id, host = nil, on_shared_storage = true, admin_password = nil)
          evacuate = {'onSharedStorage' => on_shared_storage}
          evacuate['host'] = host if host
          evacuate['adminPass'] = admin_password if admin_password
          body = {
            'evacuate' => evacuate
          }
          server_action(server_id, body)
        end
      end

      class Mock
        def evacuate_server(server_id, host, on_shared_storage, admin_password = nil)
          response = Excon::Response.new
          response.status = 202
          response
        end
      end
    end
  end
end
