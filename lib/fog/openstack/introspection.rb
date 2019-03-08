require 'yaml'

module Fog
  module OpenStack
    class Introspection < Fog::Service
      SUPPORTED_VERSIONS = /v1/.freeze

      requires :openstack_auth_url
      recognizes :openstack_auth_token, :openstack_management_url,
                 :persistent, :openstack_service_type, :openstack_service_name,
                 :openstack_tenant, :openstack_tenant_id,
                 :openstack_api_key, :openstack_username, :openstack_identity_endpoint,
                 :current_user, :current_tenant, :openstack_region,
                 :openstack_endpoint_type, :openstack_cache_ttl,
                 :openstack_project_name, :openstack_project_id,
                 :openstack_project_domain, :openstack_user_domain, :openstack_domain_name,
                 :openstack_project_domain_id, :openstack_user_domain_id, :openstack_domain_id,
                 :openstack_identity_api_version

      ## REQUESTS
      #
      request_path 'fog/openstack/introspection/requests'

      # Introspection requests
      request :create_introspection
      request :get_introspection
      request :abort_introspection
      request :get_introspection_details

      # Rules requests
      request :create_rules
      request :list_rules
      request :delete_rules_all
      request :get_rules
      request :delete_rules

      ## MODELS
      #
      model_path 'fog/openstack/introspection/models'
      model       :rules
      collection  :rules_collection

      class Mock
        def self.data
          @data ||= Hash.new do |hash, key|
            # Introspection data is *huge* we load it from a yaml file
            file = "test/fixtures/introspection.yaml"
            hash[key] = YAML.safe_load(File.read(file))
          end
        end

        def self.reset
          @data = nil
        end

        include Fog::OpenStack::Core

        def initialize(_options = {})
          @auth_token = Fog::Mock.random_base64(64)
          @auth_token_expiration = (Time.now.utc + 86_400).iso8601
        end

        def data
          self.class.data[@openstack_username]
        end

        def reset_data
          self.class.data.delete(@openstack_username)
        end
      end

      class Real
        include Fog::OpenStack::Core

        def self.not_found_class
          Fog::OpenStack::Introspection::NotFound
        end

        def default_path_prefix
          'v1'
        end

        def default_service_type
          %w[baremetal-introspection]
        end
      end
    end
  end
end