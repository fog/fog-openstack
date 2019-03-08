module Fog
  module OpenStack
    class KeyManager
      class Real
        def get_container(uuid)
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "containers/#{uuid}",
          )
        end
      end

      class Mock
      end
    end
  end
end
