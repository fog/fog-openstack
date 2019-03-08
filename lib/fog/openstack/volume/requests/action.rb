module Fog
  module OpenStack
    class Volume
      module Real
        def action(id, data)
          request(
            :body    => Fog::JSON.encode(data),
            :expects => [200, 202],
            :method  => 'POST',
            :path    => "volumes/#{id}/action"
          )
        end
      end
    end
  end
end
