module Fog
  module OpenStack
    class KeyManager
      class Real
        def replace_container_acl(uuid, options)
          request(
            :body    => Fog::JSON.encode(options),
            :expects => [200],
            :method  => 'PUT',
            :path    => "containers/#{uuid}/acl"
          )
        end
      end

      class Mock
        def replace_container_acl(_uuid, _options)
          response = Excon::Response.new
          response.status = 200
          response.body = {
            "acl_ref" => "https://10.0.2.15:9311/v1/containers/4ab86cb0-a736-48df-ae97-b10d3e5bc60a/acl"
          }
          response
        end
      end
    end
  end
end
