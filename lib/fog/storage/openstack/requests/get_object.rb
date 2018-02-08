module Fog
  module Storage
    class OpenStack
      class Mock
        def get_object(container, object, &block)
          cc = mock_container!(container)
          obj = cc.mock_object!(object)

          body, size = "", 0

          obj.each_part do |part|
            body << part.body
            size += part.bytes_used
          end

          if block_given?
            # Just send it all in one chunk.
            block.call(body, 0, size)
          end

          response = Excon::Response.new
          response.body = body
          response.headers = obj.to_headers
          response
        end
      end

      class Real
        # Get details for object
        #
        # ==== Parameters
        # * container<~String> - Name of container to look in
        # * object<~String> - Name of object to look for
        #
        def get_object(container, object, &block)
          params = {
            :expects => 200,
            :method  => 'GET',
            :path    => "#{Fog::OpenStack.escape(container)}/#{Fog::OpenStack.escape(object)}"
          }

          if block_given?
            params[:response_block] = block
          end

          request(params, false)
        end
      end
    end
  end
end
