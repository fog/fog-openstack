module Fog
  module OpenStack
    class Storage
      module PublicUrl
        # Get public_url for an object
        #
        # ==== Parameters
        # * container<~String> - Name of container to look in
        # * object<~String> - Name of object to look for
        #
        def public_url(container = nil, object = nil)
          return nil if container.nil?
          u = "#{url}/#{Fog::OpenStack.escape(container)}"
          u << "/#{Fog::OpenStack.escape(object)}" unless object.nil?
          u
        end

        private

        def url
          "#{@openstack_management_uri.scheme}://#{@openstack_management_uri.host}:"\
          "#{@openstack_management_uri.port}#{@path}"
        end
      end

      class Real
        include PublicUrl
      end

      class Mock
        include PublicUrl
      end
    end
  end
end
