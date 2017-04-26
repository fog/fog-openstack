module Fog
  module KeyManager
    class OpenStack
      class Real
        def delete_secret_acl(uuid)
          request(
              :expects => [200],
              :method  => 'DELETE',
              :path    => "secrets/#{uuid}/acl",
          )
        end

	def delete_container_acl(uuid)
          request(
              :expects => [200],
              :method  => 'DELETE',
              :path    => "containers/#{uuid}/acl",
          )
        end

      end

      class Mock
        def delete_secret_acl(_uuid)
          response = Excon::Response.new
          response.status = 200
          response.body = {
              "data" => {
                  "body" => "null"
              }
          }
        end

        def delete_container_acl(_uuid)
          response = Excon::Response.new
          response.status = 200
          response.body = {
              "data" => {
                  "body" => "null"
              }
          }
        end

      end
    end
  end
end
