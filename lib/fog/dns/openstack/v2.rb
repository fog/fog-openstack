require 'fog/dns/openstack'

module Fog
  module DNS
    class OpenStack
      class V2 < Fog::Service
        SUPPORTED_VERSIONS = /v2/

        requires   :openstack_auth_url
        recognizes :openstack_auth_token, :openstack_management_url,
                   :persistent, :openstack_service_type, :openstack_service_name,
                   :openstack_tenant, :openstack_tenant_id, :openstack_userid,
                   :openstack_api_key, :openstack_username, :openstack_identity_endpoint,
                   :current_user, :current_tenant, :openstack_region,
                   :openstack_endpoint_type, :openstack_auth_omit_default_port,
                   :openstack_project_name, :openstack_project_id,
                   :openstack_project_domain, :openstack_user_domain, :openstack_domain_name,
                   :openstack_project_domain_id, :openstack_user_domain_id, :openstack_domain_id,
                   :openstack_identity_prefix, :openstack_temp_url_key, :openstack_cache_ttl

        request_path 'fog/dns/openstack/v2/requests'

        request :list_zones

        request :get_quota
        request :update_quota

        class Mock
          def self.data
            @data ||= Hash.new do |hash, key|
              hash[key] = {
                :zones => [{
                  "id"             => "a86dba58-0043-4cc6-a1bb-69d5e86f3ca3",
                  "pool_id"        => "572ba08c-d929-4c70-8e42-03824bb24ca2",
                  "project_id"     => "4335d1f0-f793-11e2-b778-0800200c9a66",
                  "name"           => "example.org.",
                  "email"          => "joe@example.org",
                  "ttl"            => 7200,
                  "serial"         => 1_404_757_531,
                  "status"         => "ACTIVE",
                  "action"         => "CREATE",
                  "description"    => "This is an example zone.",
                  "masters"        => [],
                  "type"           => "PRIMARY",
                  "transferred_at" => '',
                  "version"        => 1,
                  "created_at"     => "2014-07-07T18:25:31.275934",
                  "updated_at"     => '',
                  "links"          => {
                    "self" => "https://127.0.0.1:9001/v2/zones/a86dba58-0043-4cc6-a1bb-69d5e86f3ca3"
                  }
                }],
                :quota => {
                  "api_export_size"   => 1000,
                  "recordset_records" => 20,
                  "zone_records"      => 500,
                  "zone_recordsets"   => 500,
                  "zones"             => 100
                }
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
            management_url.port = 9001
            management_url.path = '/v2'
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
            Fog::DNS::OpenStack::NotFound
          end

          def initialize(options = {})
            initialize_identity options

            @openstack_service_type           = options[:openstack_service_type] || ['dns']
            @openstack_service_name           = options[:openstack_service_name]

            @connection_options               = options[:connection_options] || {}

            authenticate
            set_api_path
            @persistent = options[:persistent] || false
            @connection = Fog::Core::Connection.new("#{@scheme}://#{@host}:#{@port}/", @persistent, @connection_options)
          end

          def set_api_path
            unless @path.match(SUPPORTED_VERSIONS)
              @path = Fog::OpenStack.get_supported_version_path(
                SUPPORTED_VERSIONS,
                @openstack_management_uri,
                @auth_token,
                @connection_options
              )
            end
          end
        end
      end
    end
  end
end
