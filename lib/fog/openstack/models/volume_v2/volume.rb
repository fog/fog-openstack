require 'fog/openstack/models/volume/volume'

module Fog
  module Volume
    class OpenStack
      class V2
        class Volume < Fog::Volume::OpenStack::Volume
          identity :id

          superclass.attributes.each{|attrib| attribute attrib}
          attribute :name
          attribute :description
          attribute :tenant_id, :aliases => 'os-vol-tenant-attr:tenant_id'

          def save
            requires :name, :size
            if self.id.nil?
              data = service.create_volume(name, description, size, attributes)
            else
              data = service.update_volume(self.id, attributes.reject{|k,v| k == :id})
            end
            merge_attributes(data.body['volume'])
            true
          end

          def update(attr = nil)
            requires :id
            merge_attributes(
                service.update_volume(self.id, attr || attributes).body['volume'])
            self
          end
        end
      end
    end
  end
end
