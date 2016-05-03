require 'fog/openstack/models/volume/volume'

module Fog
  module Volume
    class OpenStack
      class V1
        class Volume < Fog::Volume::OpenStack::Volume
          identity :id

          superclass.attributes.each{|attrib| attribute attrib}
          attribute :display_name, :aliases => 'displayName'
          attribute :display_description, :aliases => 'displayDescription'
          attribute :tenant_id, :aliases => 'os-vol-tenant-attr:tenant_id'

          def save
            requires :display_name, :size
            if self.id.nil?
              data = service.create_volume(display_name, display_description, size, attributes)
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
