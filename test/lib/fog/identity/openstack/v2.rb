module Fog
  module Identity
    class OpenStack
      class V2 < Fog::Service
        class Mock
          attr_reader :auth_token
          attr_reader :auth_token_expiration
          attr_reader :current_user
          attr_reader :current_tenant
          attr_reader :unscoped_token

          def self.data
            @users ||= {}
            @roles ||= {}
            @tenants ||= {}
            @ec2_credentials ||= Hash.new { |hash, key| hash[key] = {} }
            @user_tenant_membership ||= {}

            @data ||= Hash.new do |hash, key|
              hash[key] = {
                :users                  => @users,
                :roles                  => @roles,
                :tenants                => @tenants,
                :ec2_credentials        => @ec2_credentials,
                :user_tenant_membership => @user_tenant_membership
              }
            end
          end

          def self.reset!
            @data = nil
            @users = nil
            @roles = nil
            @tenants = nil
            @ec2_credentials = nil
          end

          def initialize(options = {})
            @openstack_username = options[:openstack_username] || 'admin'
            @openstack_tenant = options[:openstack_tenant] || 'admin'
            @openstack_auth_uri = URI.parse(options[:openstack_auth_url])
            @openstack_management_url = @openstack_auth_uri.to_s

            @auth_token = Fog::Mock.random_base64(64)
            @auth_token_expiration = (Time.now.utc + 86400).iso8601

            @admin_tenant = data[:tenants].values.find do |u|
              u['name'] == 'admin'
            end

            if @openstack_tenant
              @current_tenant = data[:tenants].values.find do |u|
                u['name'] == @openstack_tenant
              end

              if @current_tenant
                @current_tenant_id = @current_tenant['id']
              else
                @current_tenant_id = Fog::Mock.random_hex(32)
                @current_tenant = data[:tenants][@current_tenant_id] = {
                  'id'   => @current_tenant_id,
                  'name' => @openstack_tenant
                }
              end
            else
              @current_tenant = @admin_tenant
            end

            @current_user = data[:users].values.find do |u|
              u['name'] == @openstack_username
            end
            @current_tenant_id = Fog::Mock.random_hex(32)

            if @current_user
              @current_user_id = @current_user['id']
            else
              @current_user_id = Fog::Mock.random_hex(32)
              @current_user = data[:users][@current_user_id] = {
                'id'       => @current_user_id,
                'name'     => @openstack_username,
                'email'    => "#{@openstack_username}@mock.com",
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
            {:provider                  => 'openstack',
             :openstack_auth_url        => @openstack_auth_uri.to_s,
             :openstack_auth_token      => @auth_token,
             :openstack_management_url  => @openstack_management_url,
             :openstack_current_user_id => @openstack_current_user_id,
             :current_user              => @current_user,
             :current_tenant            => @current_tenant}
          end
        end
      end
    end
  end
end
