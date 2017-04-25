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
      end
    end
  end
end
