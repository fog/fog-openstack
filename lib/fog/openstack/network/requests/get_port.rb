module Fog
  module OpenStack
    class Network
      class Real
        def get_port(port_id)
          request(
            expects: [200],
            method: 'GET',
            path: "ports/#{port_id}"
          )
        end
      end

      class Mock
        def get_port(port_id)
          response = Excon::Response.new
          if data = self.data[:ports][port_id]
            response.status = 200
            response.body = { 'port' => data }
            response
          else
            raise Fog::OpenStack::Network::NotFound
          end
        end
      end
    end
  end
end
