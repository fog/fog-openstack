require 'fog/openstack/volume/models/volume'

module Fog
  module OpenStack
    class Volume
      class V1
        class Volume < Fog::OpenStack::Volume::Volume
          identity :id

          superclass.attributes.each { |attrib| attribute attrib }
          attribute :display_name, :aliases => 'displayName'
          attribute :display_description, :aliases => 'displayDescription'
          attribute :tenant_id, :aliases => 'os-vol-tenant-attr:tenant_id'

          def save
            requires :display_name, :size
            data = if id.nil?
                     service.create_volume(display_name, display_description, size, attributes)
                   else
                     service.update_volume(id, attributes.reject { |k, _v| k == :id })
                   end
            merge_attributes(data.body['volume'])
            true
          end

          def update(attr = nil)
            requires :id
            merge_attributes(
              service.update_volume(id, attr || attributes).body['volume']
            )
            self
          end
        end
      end
    end
  end
end
