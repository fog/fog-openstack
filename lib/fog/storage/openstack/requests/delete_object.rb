module Fog
  module Storage
    class OpenStack
      class Mock
        def delete_object(container, object)
          cc = mock_container!(container)
          cc.mock_object!(object)
          cc.remove_object(object)

          response = Excon::Response.new
          response.status = 204
          response
        end
      end

      class Real
        # Delete an existing object
        #
        # ==== Parameters
        # * container<~String> - Name of container to delete
        # * object<~String> - Name of object to delete
        #
        def delete_object(container, object)
          request(
            :expects => 204,
            :method  => 'DELETE',
            :path    => "#{Fog::OpenStack.escape(container)}/#{Fog::OpenStack.escape(object)}"
          )
        end
      end
    end
  end
end
