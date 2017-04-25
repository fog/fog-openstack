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
      end
    end
  end
end
