module Fog
  module KeyManager
    class OpenStack
      class Real
        def update_secret_acl(uuid, options)
          request(
              :body    => Fog::JSON.encode(options),
              :expects => [200],
              :method  => 'PATCH',
              :path    => "secrets/#{uuid}/acl",
          )
        end
        
	def update_container_acl(uuid, options)
          request(
              :body    => Fog::JSON.encode(options),
              :expects => [200],
              :method  => 'PATCH',
              :path    => "containers/#{uuid}/acl",
          )
      end
      end
      class Mock
        def update_secret_acl(_uuid, _options)
          response = Excon::Response.new
          response.status = 200
          response.body = {
              body=>
                  "{\"acl_ref\": \"https://10.0.2.15:9311/v1/secrets/17ca49d9-0804-4ba7-b931-d34cabaa1f04/acl\"}"
          }
          response
        end

        def update_container_acl(_uuid, _options)
          response = Excon::Response.new
          response.status = 200
          response.body = {
              body=>
                  "{\"acl_ref\": \"https://10.0.2.15:9311/v1/containers/4ab86cb0-a736-48df-ae97-b10d3e5bc60a/acl\"}"
          }
          response
        end

      end
    end
  end
end
