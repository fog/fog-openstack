require 'fog/openstack/models/volume/snapshot'

module Fog
  module Volume
    class OpenStack
      class V1
        class Snapshot < Fog::Volume::OpenStack::Snapshot
          identity :id

          attribute :display_name
          attribute :status
          attribute :display_description
          attribute :metadata
          attribute :force

          def save
            requires :display_name
            if self.id.nil?
              data = service.create_snapshot(self.attributes[:volume_id], display_name, display_description, force)
            else
              data = service.update_snapshot(self.id, attributes.reject{|k,v| k == :id})
            end
            merge_attributes(data.body['snapshot'])
            true
          end

          def create
            requires :display_name

            #volume_id, name, description, force=false
            response = service.create_snapshot(self.attributes[:volume_id],
                                                      self.attributes[:display_name],
                                                      self.attributes[:display_description],
                                                      self.attributes[:force])
            merge_attributes(response.body['snapshot'])

            self
          end
        end
      end
    end
  end
end
