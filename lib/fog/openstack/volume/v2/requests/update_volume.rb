require 'fog/openstack/volume/requests/update_volume'
require 'fog/openstack/volume/v2/requests/real'

module Fog
  module OpenStack
    class Volume
      module Real
        def update_volume(volume_id, data = {})
          data = data.select { |key| [:name, :description, :metadata].include? key }
          request(
            body: Fog::JSON.encode('volume' => data),
            expects: 200,
            method: 'PUT',
            path: "volumes/#{volume_id}"
          )
        end
      end
    end
  end
end
