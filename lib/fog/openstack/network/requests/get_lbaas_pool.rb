module Fog
  module OpenStack
    class Network
      class Real
        def get_lbaas_pool(pool_id)
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "lbaas/pools/#{pool_id}"
          )
        end
      end

      class Mock
        def get_lbaas_pool(pool_id)
          response = Excon::Response.new
          if data = self.data[:lbaas_pools][pool_id]
            response.status = 200
            response.body = {'pool' => data}
            response
          else
            raise Fog::OpenStack::Network::NotFound
          end
        end
      end
    end
  end
end
