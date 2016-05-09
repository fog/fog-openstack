

module Fog
  module Identity
    class OpenStack < Fog::Service
      requires :openstack_auth_url
      recognizes :openstack_auth_token, :openstack_management_url, :persistent,
                 :openstack_service_type, :openstack_service_name, :openstack_tenant,
                 :openstack_endpoint_type, :openstack_region, :openstack_domain_id,
                 :openstack_project_name, :openstack_domain_name,
                 :openstack_user_domain, :openstack_project_domain,
                 :openstack_user_domain_id, :openstack_project_domain_id,
                 :openstack_api_key, :openstack_current_user_id, :openstack_userid, :openstack_username,
                 :current_user, :current_user_id, :current_tenant, :openstack_cache_ttl,
                 :provider, :openstack_identity_prefix, :openstack_endpoint_path_matches

      # Fog::Identity::OpenStack.new() will return a Fog::Identity::OpenStack::V2 or a Fog::Identity::OpenStack::V3,
      #  depending on whether the auth URL is for an OpenStack Identity V2 or V3 API endpoint
      def self.new(args = {})
        if self.inspect == 'Fog::Identity::OpenStack'
          identity = super
          config = identity.config
          service = identity.v3? ? Fog::Identity::OpenStack::V3.new(config) : Fog::Identity::OpenStack::V2.new(config)
        else
          service = Fog::Service.new(args)
        end
        service
      end

      class Mock
        attr_reader :config

        def initialize(options = {})
          @openstack_auth_uri = URI.parse(options[:openstack_auth_url])
          @openstack_identity_prefix = options[:openstack_identity_prefix]
          @config = options
        end

        def v3?
          if @openstack_identity_prefix
            @openstack_identity_prefix =~ /v3/
          else
            @openstack_auth_uri && @openstack_auth_uri.path =~ %r{/v3}
          end
        end
      end

      class Real
        DEFAULT_SERVICE_TYPE_V3 = %w(identity_v3 identityv3 identity).collect(&:freeze).freeze
        DEFAULT_SERVICE_TYPE    = %w(identity).collect(&:freeze).freeze

        def self.not_found_class
          Fog::Identity::OpenStack::NotFound
        end
        include Fog::OpenStack::Common

        def initialize(options = {})
          if options.respond_to?(:config_service?) && options.config_service?
            configure(options)
            return
          end

          initialize_identity(options)

          @openstack_service_type   = options[:openstack_service_type] || default_service_type(options)
          @openstack_service_name   = options[:openstack_service_name]

          @connection_options       = options[:connection_options] || {}

          @openstack_endpoint_type  = options[:openstack_endpoint_type] || 'adminURL'
          initialize_endpoint_path_matches(options)

          authenticate

          if options[:openstack_identity_prefix]
            @path = "/#{options[:openstack_identity_prefix]}/#{@path}"
          end

          @persistent = options[:persistent] || false
          @connection = Fog::Core::Connection.new("#{@scheme}://#{@host}:#{@port}", @persistent, @connection_options)
        end

        def v3?
          @path && @path =~ %r{/v3}
        end

        def config_service?
          true
        end

        def config
          self
        end

        private

        def default_service_type(options)
          unless options[:openstack_identity_prefix]
            if @openstack_auth_uri.path =~ %r{/v3} ||
               (options[:openstack_endpoint_path_matches] && options[:openstack_endpoint_path_matches] =~ '/v3')
              return DEFAULT_SERVICE_TYPE_V3
            end
          end
          DEFAULT_SERVICE_TYPE
        end

        def initialize_endpoint_path_matches(options)
          if options[:openstack_endpoint_path_matches]
            @openstack_endpoint_path_matches = options[:openstack_endpoint_path_matches]
          end
        end

        def configure(source)
          source.instance_variables.each do |v|
            instance_variable_set(v, source.instance_variable_get(v))
          end
        end
      end
    end
  end
end
