require 'fog/openstack/models/model'

module Fog
  module Volume
    class OpenStack
      class Snapshot < Fog::OpenStack::Model

        def update(data)
          requires :id

          response = service.update_snapshot(self.id, data)
          merge_attributes(response.body['snapshot'])

          self
        end

        def destroy
          requires :id
          service.delete_snapshot(self.id)
          true
        end
      end
    end
  end
end