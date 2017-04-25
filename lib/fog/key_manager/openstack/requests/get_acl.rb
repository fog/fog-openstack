module Fog
  module KeyManager
    class OpenStack
      class Real
        def get_secret_acl(uuid)
          request(
              :expects => [200],
              :method  => 'GET',
              :path    => "secrets/#{uuid}/acl",
          )
        end
        
	def get_container_acl(uuid)
          request(
              :expects => [200],
              :method  => 'GET',
              :path    => "containers/#{uuid}/acl",
          )
        end

      end

      class Mock
      end
    end
  end
end
