module Fog
  module OpenStack
    class Network
      class Real
        def get_subnet(subnet_id)
          request(
            expects: [200],
            method: 'GET',
            path: "subnets/#{subnet_id}"
          )
        end
      end

      class Mock
        def get_subnet(subnet_id)
          response = Excon::Response.new
          if data = self.data[:subnets][subnet_id]
            response.status = 200
            response.body = {
              "subnet" => data
            }
            response
          else
            raise Fog::OpenStack::Network::NotFound
          end
        end
      end
    end
  end
end
