require 'fog/openstack/models/volume/snapshot'

module Fog
  module Volume
    class OpenStack
      class V2
        class Snapshot < Fog::Volume::OpenStack::Snapshot
          identity :id

          attribute :name
          attribute :status
          attribute :description
          attribute :metadata
          attribute :force

          def save
            requires :name
            if self.id.nil?
              data = service.create_snapshot(self.attributes[:volume_id], name, description, force)
            else
              data = service.update_snapshot(self.id, attributes.reject{|k,v| k == :id})
            end
            merge_attributes(data.body['snapshot'])
            true
          end

          def create
            requires :name

            #volume_id, name, description, force=false
            response = service.create_snapshot(self.attributes[:volume_id],
                                                      self.attributes[:name],
                                                      self.attributes[:description],
                                                      self.attributes[:force])
            merge_attributes(response.body['snapshot'])

            self
          end
        end
      end
    end
  end
end
