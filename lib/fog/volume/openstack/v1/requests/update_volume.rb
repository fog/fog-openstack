require 'fog/volume/openstack/requests/update_volume'
require 'fog/volume/openstack/v1/requests/real'

module Fog
  module Volume
    class OpenStack
      module Real
        def update_volume(volume_id, data = {})
          request(
            :body    => Fog::JSON.encode('volume' => data),
            :expects => 200,
            :method  => 'PUT',
            :path    => "volumes/#{volume_id}"
          )
        end
      end
    end
  end
end
