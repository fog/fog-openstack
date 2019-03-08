module Fog
  module OpenStack
    class  ContainerInfra
      class Real
        def create_cluster(params)
          request(
            :expects => [202, 201, 200],
            :method  => 'POST',
            :path    => "clusters",
            :body    => Fog::JSON.encode(params)
          )
        end
      end

      class Mock
        def create_cluster(_params)
          response = Excon::Response.new
          response.status = 202
          response.body = {
            "uuid" => "746e779a-751a-456b-a3e9-c883d734946f"
          }
          response
        end
      end
    end
  end
end
