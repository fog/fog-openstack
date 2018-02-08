

module Fog
  module Storage
    class OpenStack < Fog::Service
      requires   :openstack_auth_url
      recognizes :openstack_auth_token, :openstack_management_url,
                 :persistent, :openstack_service_type, :openstack_service_name,
                 :openstack_tenant, :openstack_tenant_id, :openstack_userid,
                 :openstack_api_key, :openstack_username, :openstack_identity_endpoint,
                 :current_user, :current_tenant, :openstack_region,
                 :openstack_endpoint_type, :openstack_auth_omit_default_port,
                 :openstack_project_name, :openstack_project_id, :openstack_cache_ttl,
                 :openstack_project_domain, :openstack_user_domain, :openstack_domain_name,
                 :openstack_project_domain_id, :openstack_user_domain_id, :openstack_domain_id,
                 :openstack_identity_prefix, :openstack_temp_url_key

      model_path 'fog/storage/openstack/models'
      model       :directory
      collection  :directories
      model       :file
      collection  :files

      request_path 'fog/storage/openstack/requests'
      request :copy_object
      request :delete_container
      request :delete_object
      request :delete_multiple_objects
      request :delete_static_large_object
      request :get_container
      request :get_containers
      request :get_object
      request :get_object_http_url
      request :get_object_https_url
      request :head_container
      request :head_containers
      request :head_object
      request :put_container
      request :put_object
      request :post_object
      request :put_object_manifest
      request :put_dynamic_obj_manifest
      request :put_static_obj_manifest
      request :post_set_meta_temp_url_key
      request :public_url

      class Mock
        class MockContainer
          attr_reader :objects, :meta, :service

          # Create a new container. Generally, you should call
          # {Fog::Storage::OpenStack#add_container} instead.
          def initialize(service)
            @service = service
            @objects, @meta = {}, {}
          end

          # Determine if this container contains any MockObjects or not.
          #
          # @return [Boolean]
          def empty?
            @objects.empty?
          end

          # Total sizes of all objects added to this container.
          #
          # @return [Integer] The number of bytes occupied by each contained
          #   object.
          def bytes_used
            @objects.values.map { |o| o.bytes_used }.reduce(0) { |a, b| a + b }
          end

          # Render the HTTP headers that would be associated with this
          # container.
          #
          # @return [Hash<String, String>] Any metadata supplied to this
          #   container, plus additional headers indicating the container's
          #   size.
          def to_headers
            @meta.merge({
              'X-Container-Object-Count' => @objects.size,
              'X-Container-Bytes-Used' => bytes_used
            })
          end

          # Access a MockObject within this container by (unescaped) name.
          #
          # @return [MockObject, nil] Return the MockObject at this name if
          #   one exists; otherwise, `nil`.
          def mock_object(name)
            @objects[(name)]
          end

          # Access a MockObject with a specific name, raising a
          # ` Fog::Storage::OpenStack::NotFound` exception if none are present.
          #
          # @param name [String] (Unescaped) object name.
          # @return [MockObject] The object within this container with the
          #   specified name.
          def mock_object!(name)
            mock_object(name) or raise  Fog::Storage::OpenStack::NotFound.new
          end

          # Add a new MockObject to this container. An existing object with
          # the same name will be overwritten.
          #
          # @param name [String] The object's name, unescaped.
          # @param data [String, #read] The contents of the object.
          def add_object(name, data)
            @objects[(name)] = MockObject.new(data, service)
          end

          # Remove a MockObject from the container by name. No effect if the
          # object is not present beforehand.
          #
          # @param name [String] The (unescaped) object name to remove.
          def remove_object(name)
            @objects.delete (name)
          end
        end

        class MockObject
          attr_reader :hash, :bytes_used, :content_type, :last_modified
          attr_reader :body, :meta, :service
          attr_accessor :static_manifest

          # Construct a new object. Generally, you should call
          # {MockContainer#add_object} instead of instantiating these directly.
          def initialize(data, service)
            data = Fog::Storage.parse_data(data)
            @service = service

            @bytes_used = data[:headers]['Content-Length']
            @content_type = data[:headers]['Content-Type']
            if data[:body].respond_to? :read
              @body = data[:body].read
            elsif data[:body].respond_to? :body
              @body = data[:body].body
            else
              @body = data[:body]
            end
            @last_modified = Time.now.utc
            @hash = Digest::MD5.hexdigest(@body)
            @meta = {}
            @static_manifest = false
          end

          # Determine if this object was created as a static large object
          # manifest.
          #
          # @return [Boolean]
          def static_manifest?
            @static_manifest
          end

          # Determine if this object has the metadata header that marks it as a
          # dynamic large object manifest.
          #
          # @return [Boolean]
          def dynamic_manifest?
            ! large_object_prefix.nil?
          end

          # Iterate through each MockObject that contains a part of the data for
          # this logical object. In the normal case, this will only yield the
          # receiver directly. For dynamic and static large object manifests,
          # however, this call will yield each MockObject that contains a part
          # of the whole, in sequence.
          #
          # Manifests that refer to containers or objects that don't exist will
          # skip those sections and log a warning, instead.
          #
          # @yield [MockObject] Each object that holds a part of this logical
          #   object.
          def each_part
            case
            when dynamic_manifest?
              # Concatenate the contents and sizes of each matching object.
              # Note that cname and oprefix are already escaped.
              cname, oprefix = large_object_prefix.split('/', 2)

              target_container = service.data[cname]
              if target_container
                all = target_container.objects.keys
                matching = all.select { |name| name.start_with? oprefix }
                keys = matching.sort

                keys.each do |name|
                  yield target_container.objects[name]
                end
              else
                Fog::Logger.warning "Invalid container in dynamic object manifest: #{cname}"
                yield self
              end
            when static_manifest?
              Fog::JSON.decode(body).each do |segment|
                cname, oname = segment['path'].split('/', 2)

                cont = service.mock_container cname
                unless cont
                  Fog::Logger.warning "Invalid container in static object manifest: #{cname}"
                  next
                end

                obj = cont.mock_object oname
                unless obj
                  Fog::Logger.warning "Invalid object in static object manifest: #{oname}"
                  next
                end

                yield obj
              end
            else
              yield self
            end
          end

          # Access the object name prefix that controls which other objects
          # comprise a dynamic large object.
          #
          # @return [String, nil] The object name prefix, or `nil` if none is
          #   present.
          def large_object_prefix
            @meta['X-Object-Manifest']
          end

          # Construct the fake HTTP headers that should be returned on requests
          # targetting this object. Includes computed `Content-Type`,
          # `Content-Length`, `Last-Modified` and `ETag` headers in addition to
          # whatever metadata has been associated with this object manually.
          #
          # @return [Hash<String, String>] Header values stored in a Hash.
          def to_headers
            {
              'Content-Type' => @content_type,
              'Content-Length' => @bytes_used,
              'Last-Modified' => @last_modified.strftime('%a, %b %d %Y %H:%M:%S %Z'),
              'ETag' => @hash
            }.merge(@meta)
          end
        end

        def self.data
          @data ||= Hash.new do |hash, key|
            hash[key] = {}
          end
        end

        def self.reset
          @data = nil
        end

        def initialize(options = {})
          @openstack_api_key = options[:openstack_api_key]
          @openstack_username = options[:openstack_username]
          @openstack_project_id = options[:openstack_project_id]
          @openstack_domain_name = options[:openstack_domain_name]
          @openstack_temp_url_key = options[:openstack_temp_url_key]

          uri = URI.parse(options[:openstack_management_url])
          @host = uri.host
          @port = uri.port
          @path = uri.path
          @scheme = uri.scheme
        rescue URI::InvalidURIError => _ex
          @scheme = 'https'
          @host = 'www.opensctak.url'
          @path = '/v1/AUTH_1234'
        end

        def data
          self.class.data[@openstack_username]
        end

        def reset_data
          self.class.data.delete(@openstack_username)
        end

        def change_account(account)
          @original_path ||= @path
          version_string = @original_path.split('/')[1]
          @path = "/#{version_string}/#{account}"
        end

        def reset_account_name
          @path = @original_path
        end

        # Access a MockContainer with the specified name, if one exists.
        #
        # @param cname [String] The (unescaped) container name.
        # @return [MockContainer, nil] The named MockContainer, or `nil` if
        #   none exist.
        def mock_container(cname)
          data[(cname)]
        end

        # Access a MockContainer with the specified name, raising a
        # { Fog::Storage::OpenStack::NotFound} exception if none exist.
        #
        # @param cname [String] The (unescaped) container name.
        # @throws [ Fog::Storage::OpenStack::NotFound] If no container with the
        #   given name exists.
        # @return [MockContainer] The existing MockContainer.
        def mock_container!(cname)
          mock_container(cname) or raise  Fog::Storage::OpenStack::NotFound.new
        end

        def add_container(name)
          data[(name)] = MockContainer.new(self)
        end

      end

      class Real
        include Fog::OpenStack::Core

        def self.not_found_class
          Fog::Storage::OpenStack::NotFound
        end

        def initialize(options = {})
          initialize_identity options

          @openstack_service_type           = options[:openstack_service_type] || ['object-store']
          @openstack_service_name           = options[:openstack_service_name]

          @connection_options               = options[:connection_options] || {}

          authenticate
          @persistent = options[:persistent] || false
          @connection = Fog::Core::Connection.new("#{@scheme}://#{@host}:#{@port}", @persistent, @connection_options)
        end

        # Change the current account while re-using the auth token.
        #
        # This is usefull when you have an admin role and you're able
        # to HEAD other user accounts, set quotas, list files, etc.
        #
        # For example:
        #
        #     # List current user account details
        #     service = Fog::Storage[:openstack]
        #     service.request :method => 'HEAD'
        #
        # Would return something like:
        #
        #     Account:                      AUTH_1234
        #     Date:                         Tue, 05 Mar 2013 16:50:52 GMT
        #     X-Account-Bytes-Used:         0 (0.00 Bytes)
        #     X-Account-Container-Count:    0
        #     X-Account-Object-Count:       0
        #
        # Now let's change the account
        #
        #     service.change_account('AUTH_3333')
        #     service.request :method => 'HEAD'
        #
        # Would return something like:
        #
        #     Account:                      AUTH_3333
        #     Date:                         Tue, 05 Mar 2013 16:51:53 GMT
        #     X-Account-Bytes-Used:         23423433
        #     X-Account-Container-Count:    2
        #     X-Account-Object-Count:       10
        #
        # If we wan't to go back to our original admin account:
        #
        #     service.reset_account_name
        #
        def change_account(account)
          @original_path ||= @path
          version_string = @path.split('/')[1]
          @path = "/#{version_string}/#{account}"
        end

        def reset_account_name
          @path = @original_path
        end
      end
    end
  end
end
