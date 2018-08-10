require 'fog/openstack/auth/catalog'

module Fog
  module OpenStack
    module Auth
      module Catalog
        class V2
          include Fog::OpenStack::Auth::Catalog

          def endpoint_match(endpoint, interface, region)
            if region
              return true if endpoint['region'] == region && endpoint["#{interface}URL"]
            else
              return true if endpoint["#{interface}URL"]
            end
          end

          def endpoint_url(endpoint, interface)
            return endpoint["#{interface}URL"]
          end
        end
      end
    end
  end
end
