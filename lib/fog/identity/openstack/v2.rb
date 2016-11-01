require 'fog/identity/openstack'

module Fog
  module Identity
    class OpenStack
      class V2 < Fog::Service
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
                   :openstack_identity_prefix, :openstack_endpoint_path_matches

        model_path 'fog/identity/openstack/v2/models'
        model :tenant
        collection :tenants
        model :user
        collection :users
        model :role
        collection :roles
        model :ec2_credential
        collection :ec2_credentials

        request_path 'fog/identity/openstack/v2/requests'

        request :check_token
        request :validate_token

        request :list_tenants
        request :create_tenant
        request :get_tenant
        request :get_tenants_by_id
        request :get_tenants_by_name
        request :update_tenant
        request :delete_tenant

        request :list_users
        request :create_user
        request :update_user
        request :delete_user
        request :get_user_by_id
        request :get_user_by_name
        request :add_user_to_tenant
        request :remove_user_from_tenant

        request :list_endpoints_for_token
        request :list_roles_for_user_on_tenant
        request :list_user_global_roles

        request :create_role
        request :delete_role
        request :delete_user_role
        request :create_user_role
        request :get_role
        request :list_roles

        request :set_tenant

        request :create_ec2_credential
        request :delete_ec2_credential
        request :get_ec2_credential
        request :list_ec2_credentials

        class Real < Fog::Identity::OpenStack::Real
          private

          def default_service_type(_)
            DEFAULT_SERVICE_TYPE
          end
        end
      end
    end
  end
end
