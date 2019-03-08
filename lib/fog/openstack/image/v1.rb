require 'fog/openstack/image'

module Fog
  module OpenStack
    class Image
      class V1 < Fog::Service
        SUPPORTED_VERSIONS = /v1(\.(0|1))*/

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

        model_path 'fog/openstack/image/v1/models'

        model       :image
        collection  :images

        request_path 'fog/openstack/image/v1/requests'

        request :list_public_images
        request :list_public_images_detailed
        request :get_image
        request :create_image
        request :update_image
        request :get_image_members
        request :update_image_members
        request :get_shared_images
        request :add_member_to_image
        request :remove_member_from_image
        request :delete_image
        request :get_image_by_id
        request :set_tenant

        class Mock
          def self.data
            @data ||= Hash.new do |hash, key|
              hash[key] = {
                :images => {}
              }
            end
          end

          def self.reset
            @data = nil
          end

          def initialize(options = {})
            @openstack_username = options[:openstack_username]
            @openstack_tenant   = options[:openstack_tenant]
            @openstack_auth_uri = URI.parse(options[:openstack_auth_url])

            @auth_token = Fog::Mock.random_base64(64)
            @auth_token_expiration = (Time.now.utc + 86400).iso8601

            management_url = URI.parse(options[:openstack_auth_url])
            management_url.port = 9292
            management_url.path = '/v1'
            @openstack_management_url = management_url.to_s

            @data ||= {:users => {}}
            unless @data[:users].detect { |u| u['name'] == options[:openstack_username] }
              id = Fog::Mock.random_numbers(6).to_s
              @data[:users][id] = {
                'id'       => id,
                'name'     => options[:openstack_username],
                'email'    => "#{options[:openstack_username]}@mock.com",
                'tenantId' => Fog::Mock.random_numbers(6).to_s,
                'enabled'  => true
              }
            end
          end

          def data
            self.class.data[@openstack_username]
          end

          def reset_data
            self.class.data.delete(@openstack_username)
          end

          def credentials
            {:provider                 => 'openstack',
             :openstack_auth_url       => @openstack_auth_uri.to_s,
             :openstack_auth_token     => @auth_token,
             :openstack_region         => @openstack_region,
             :openstack_management_url => @openstack_management_url}
          end
        end

        class Real
          include Fog::OpenStack::Core

          def self.not_found_class
            Fog::OpenStack::Image::NotFound
          end

          def default_endpoint_type
            'admin'
          end

          def default_path_prefix
            'v1'
          end

          def default_service_type
            %w[imagev1]
          end
        end
      end
    end
  end
end
