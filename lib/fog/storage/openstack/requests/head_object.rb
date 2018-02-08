module Fog
  module Storage
    class OpenStack
      class Mock
        def head_object(container, object)
          c = mock_container! container
          o = c.mock_object! object

          headers = o.to_headers

          hashes, length = [], 0
          o.each_part do |part|
            hashes << part.hash
            length += part.bytes_used
          end

          headers['Etag'] = "\"#{Digest::MD5.hexdigest(hashes.join)}\""
          headers['Content-Length'] = length.to_s
          headers['X-Static-Large-Object'] = "True" if o.static_manifest?

          response = Excon::Response.new
          response.status = 200
          response.headers = headers
          response
        end
      end

      class Real
        # Get headers for object
        #
        # ==== Parameters
        # * container<~String> - Name of container to look in
        # * object<~String> - Name of object to look for
        #
        def head_object(container, object)
          request({
                    :expects => 200,
                    :method  => 'HEAD',
                    :path    => "#{Fog::OpenStack.escape(container)}/#{Fog::OpenStack.escape(object)}"
                  }, false)
        end
      end
    end
  end
end
