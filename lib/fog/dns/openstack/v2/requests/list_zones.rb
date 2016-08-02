module Fog
  module DNS
    class OpenStack
      class V2
        class Real
          def list_zones(options = {})
            request(
              :expects => 200,
              :method  => 'GET',
              :path    => 'zones',
              :query   => options
            )
          end
        end

        class Mock
          def list_zones(_options = {})
            response = Excon::Response.new
            response.status = 200
            response.body = {'zones' => data[:zones]}
            response
          end
        end
      end
    end
  end
end
