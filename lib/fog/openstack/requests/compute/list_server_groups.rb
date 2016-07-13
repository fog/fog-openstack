module Fog
  module Compute
    class OpenStack
      class Real
        def list_server_groups(options = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => 'os-server-groups',
            :query   => options
          )
        end
      end

      class Mock
        def list_server_groups(options = {})
          Excon::Response.new(
            :body   => { 'server_groups' => [
              ] },
            :status => 200
          )
        end
      end
    end
  end
end
