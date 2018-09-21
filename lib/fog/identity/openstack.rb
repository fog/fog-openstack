module Fog
  module Identity
    class OpenStack < Fog::Service
      autoload :V2, 'fog/identity/openstack/v2'
      autoload :V3, 'fog/identity/openstack/v3'

      def self.new(args = {})
        version = if args[:openstack_identity_api_version] =~ /(v)*2(\.0)*/i
                    '2.0'
                  elsif args[:openstack_auth_url] =~ /v3|v2(\.0)*/
                    # Deprecated from fog-openstack 0.2.0
                    # Will be removed in future after hard deprecation is enforced for a couple of releases
                    Fog::Logger.deprecation("An authentication URL including a version is deprecated")
                    case args[:openstack_auth_url]
                    when /\/v3(\/)*.*$/
                      args[:openstack_auth_url].gsub!(/\/v3(\/)*.*$/, '')
                      args[:no_path_prefix] = true
                      '3'
                    when /\/v2(\.0)*(\/)*.*$/
                      args[:openstack_auth_url].gsub!(/\/v2(\.0)*(\/)*.*$/, '')
                      args[:no_path_prefix] = true
                      '2.0'
                    end
                  end

        case version
        when '2.0'
          Fog::Identity::OpenStack::V2.new(args)
        else
          Fog::Identity::OpenStack::V3.new(args)
        end
      end

      class Mock
        attr_reader :config

        def initialize(options = {})
          @openstack_auth_uri = URI.parse(options[:openstack_auth_url])
          @config = options
        end
      end

      class Real
        include Fog::OpenStack::Core

        def self.not_found_class
          Fog::Identity::OpenStack::NotFound
        end

        def config_service?
          true
        end

        def config
          self
        end

        def default_endpoint_type
          'admin'
        end

        private

        def configure(source)
          source.instance_variables.each do |v|
            instance_variable_set(v, source.instance_variable_get(v))
          end
        end
      end
    end
  end
end
