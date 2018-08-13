

module Fog
  module Identity
    class OpenStack < Fog::Service
      autoload :V2, 'fog/identity/openstack/v2'
      autoload :V3, 'fog/identity/openstack/v3'

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

      def self.new(args = {})
        if args[:openstack_identity_legacy_version]
          version = '2.0'
        else
          url = Fog.credentials[:openstack_auth_url] || args[:openstack_auth_url]
          if url
            uri = URI(url)
            version = '2.0' if uri.path =~ /v2\.0/
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
