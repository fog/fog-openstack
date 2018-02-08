module Fog
  module Storage
    class OpenStack
      class Mock
        def put_container(name, options = {})
          existed = ! mock_container(name).nil?
          container = add_container(name)
          options.keys.each do |k|
            container.meta[k] = options[k].to_s if k =~ /^X-Container-Meta/
          end

          response = Excon::Response.new
          response.status = existed ? 202 : 201
          response
        end
      end

      class Real
        # Create a new container
        #
        # ==== Parameters
        # * name<~String> - Name for container, should be < 256 bytes and must not contain '/'
        #
        def put_container(name, options = {})
          headers = options[:headers] || {}
          headers['X-Container-Read'] = '.r:*' if options[:public]
          headers['X-Remove-Container-Read'] = 'x' if options[:public] == false
          request(
            :expects => [201, 202],
            :method  => 'PUT',
            :path    => Fog::OpenStack.escape(name),
            :headers => headers
          )
        end
      end
    end
  end
end
