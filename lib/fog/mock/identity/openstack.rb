module Fog
  module Identity
    class OpenStack < Fog::Service
      class Mock
        attr_reader :config

        def initialize(options = {})
          @openstack_auth_uri = URI.parse(options[:openstack_auth_url])
          @config = options
        end
      end
    end
  end
end
