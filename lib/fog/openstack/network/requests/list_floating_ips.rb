module Fog
  module OpenStack
    class Network
      class Real
        def list_floating_ips(filters = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => 'floatingips',
            :query   => filters
          )
        end
      end

      class Mock
        def list_floating_ips(_filters = {})
          Excon::Response.new(
            :body   => {'floatingips' => data[:floating_ips].values},
            :status => 200
          )
        end
      end
    end
  end
end
