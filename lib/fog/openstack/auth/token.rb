require 'fog/openstack/auth/token/v2'
require 'fog/openstack/auth/token/v3'
require 'fog/openstack/auth/catalog/v2'
require 'fog/openstack/auth/catalog/v3'

module Fog
  module OpenStack
    module Auth
      module Token
        attr_reader :catalog, :expires, :tenant, :token, :user, :data

        class ExpiryError < RuntimeError; end
        class StandardError < RuntimeError; end
        class URLError < RuntimeError; end

        def self.build(auth)
          if auth[:openstack_identity_api_version] =~ /(v)*2(\.0)*/i ||
             auth[:openstack_tenant_id] || auth[:openstack_tenant]
            Fog::OpenStack::Auth::Token::V2.new(auth)
          else
            Fog::OpenStack::Auth::Token::V3.new(auth)
          end
        end

        def initialize(auth)
          raise URLError, 'No URL provided' if auth[:openstack_auth_url].nil? || auth[:openstack_auth_url].empty?
          @creds = {
            :data => build_credentials(auth),
            :uri  => URI.parse(auth[:openstack_auth_url])
          }
          response = authenticate(@creds)
          set(response)
        end

        def get
          set(authenticate(@creds)) if expired?
          @token
        end

        private

        def authenticate(creds)
          connection_options = {}
          connection = Fog::Core::Connection.new(creds[:uri].to_s, false, connection_options)

          request = {
            :expects => [200, 201],
            :headers => {'Content-Type' => 'application/json'},
            :body    => Fog::JSON.encode(creds[:data]),
            :method  => 'POST',
            :path    => creds[:uri].path + path
          }

          connection.request(request)
        end

        def expired?
          if @expires.nil? || @expires.empty?
            raise ExpiryError, 'Missing token expiration data'
          end
          Time.parse(@expires) < Time.now.utc
        end

        def refresh
          raise StandardError, "__method__ not implemented yet!"
        end
      end
    end
  end
end
