require 'fog/openstack/models/collection'
require 'fog/openstack/models/metering/event'

module Fog
  module Metering
    class OpenStack
      class Events < Fog::OpenStack::Collection
        model Fog::Metering::OpenStack::Event

        def all(detailed=true)
          load_response(service.list_events)
        end

        def find_by_id(message_id)
          event = service.get_event(message_id).body
          new(event)
        rescue Fog::Metering::OpenStack::NotFound
          nil
        end
      end
    end
  end
end
