module Fog
  module KeyManager
    class OpenStack
      class Real
        def replace_secret_acl(uuid, options)
          request(
              :body    => Fog::JSON.encode(options),
              :expects => [200],
              :method  => 'PUT',
              :path    => "secrets/#{uuid}/acl",
          )
        end
        
	def replace_container_acl(uuid, options)
          request(
              :body    => Fog::JSON.encode(options),
              :expects => [200],
              :method  => 'PUT',
              :path    => "containers/#{uuid}/acl",
          )
      end
     end
      class Mock
      end
    end
  end
end
