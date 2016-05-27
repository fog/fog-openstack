require 'fog/openstack/models/collection'
require 'fog/openstack/models/monitoring/notification_method'

module Fog
  module Monitoring
    class OpenStack
      class NotificationMethods < Fog::OpenStack::Collection
        model Fog::Monitoring::OpenStack::NotificationMethod

        def all(options = {})
          load_response(service.list_notification_methods(options), 'elements')
        end

        def create(attributes)
          super(attributes)
        end

        def patch(attributes)
          super(attributes)
        end

        def find_by_id(id)
          cached_notification_method = detect { |notification_method| notification_method.id == id }
          return cached_notification_method if cached_notification_method
          notification_method_hash = service.get_notification_method(id).body
          Fog::Monitoring::OpenStack::NotificationMethod.new(
            notification_method_hash.merge(:service => service)
          )
        end

        def destroy(id)
          notification_method = find_by_id(id)
          notification_method.destroy
        end
      end
    end
  end
end
