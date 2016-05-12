module Fog
  module OpenStack
    module Core
      attr_accessor :auth_token
      attr_reader :openstack_cache_ttl
      attr_reader :auth_token_expiration
      attr_reader :current_user
      attr_reader :current_user_id
      attr_reader :current_tenant
      attr_reader :openstack_domain_name
      attr_reader :openstack_user_domain
      attr_reader :openstack_project_domain
      attr_reader :openstack_domain_id
      attr_reader :openstack_user_domain_id
      attr_reader :openstack_project_id
      attr_reader :openstack_project_domain_id
      attr_reader :openstack_identity_prefix

      def initialize_identity options
        # Create @openstack_* instance variables from all :openstack_* options
        options.select{|x|x.to_s.start_with? 'openstack'}.each do |openstack_param, value|
          instance_variable_set "@#{openstack_param}".to_sym, value
        end

        @auth_token        ||= options[:openstack_auth_token]
        @openstack_identity_public_endpoint = options[:openstack_identity_endpoint]

        @openstack_auth_uri    = URI.parse(options[:openstack_auth_url])
        @openstack_must_reauthenticate  = false
        @openstack_endpoint_type = options[:openstack_endpoint_type] || 'publicURL'

        @openstack_cache_ttl = options[:openstack_cache_ttl] || 0

        unless @auth_token
          missing_credentials = Array.new

          missing_credentials << :openstack_api_key unless @openstack_api_key
          unless @openstack_username || @openstack_userid
            missing_credentials << 'openstack_username or openstack_userid'
          end
          raise ArgumentError, "Missing required arguments: #{missing_credentials.join(', ')}" unless missing_credentials.empty?
        end

        @current_user = options[:current_user]
        @current_user_id = options[:current_user_id]
        @current_tenant = options[:current_tenant]

      end

      def credentials
        options =  {
          :provider                    => 'openstack',
          :openstack_auth_url          => @openstack_auth_uri.to_s,
          :openstack_auth_token        => @auth_token,
          :openstack_identity_endpoint => @openstack_identity_public_endpoint,
          :current_user                => @current_user,
          :current_user_id             => @current_user_id,
          :current_tenant              => @current_tenant,
          :unscoped_token              => @unscoped_token}
          openstack_options.merge options
        end

        def reload
          @connection.reset
        end

        private

        def openstack_options
          options={}
          # Create a hash of (:openstack_*, value) of all the @openstack_* instance variables
          self.instance_variables.select{|x|x.to_s.start_with? '@openstack'}.each do |openstack_param|
            option_name = openstack_param.to_s[1..-1]
            options[option_name.to_sym] = instance_variable_get openstack_param
          end
          options
        end

        def authenticate
          if !@openstack_management_url || @openstack_must_reauthenticate

            options = openstack_options

            options[:openstack_auth_token] = @openstack_must_reauthenticate ? nil : @openstack_auth_token

            credentials = Fog::OpenStack.authenticate(options, @connection_options)

            @current_user = credentials[:user]
            @current_user_id = credentials[:current_user_id]
            @current_tenant = credentials[:tenant]

            @openstack_must_reauthenticate = false
            @auth_token = credentials[:token]
            @openstack_management_url = credentials[:server_management_url]
            @unscoped_token = credentials[:unscoped_token]
          else
            @auth_token = @openstack_auth_token
          end
          @openstack_management_uri = URI.parse(@openstack_management_url)

          @host   = @openstack_management_uri.host
          @path   = @openstack_management_uri.path
          @path.sub!(/\/$/, '')
          @port   = @openstack_management_uri.port
          @scheme = @openstack_management_uri.scheme

          # Not all implementations have identity service in the catalog
          if @openstack_identity_public_endpoint || @openstack_management_url
            @identity_connection = Fog::Core::Connection.new(
            @openstack_identity_public_endpoint || @openstack_management_url,
            false, @connection_options)
          end

          true
        end
      end
    end
  end
