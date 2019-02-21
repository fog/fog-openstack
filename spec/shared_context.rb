require 'vcr'
#
# There are basically two modes of operation for these specs.
#
# 1. ENV[OS_AUTH_URL] exists: talk to an actual OpenStack and record HTTP
#    traffic in VCRs at "spec/debug" (credentials are read from the conventional
#    environment variables: OS_AUTH_URL, OS_USERNAME, OS_PASSWORD etc.)
# 2. otherwise (under Travis etc.): use VCRs at "spec/fixtures/openstack/#{service}"
#
# When you develop a new unit test or change an existing one:
#
# 1. Record interactions against an actual OpenStack (Devstack is usually
#    enough if configured correctly) using the first mode from above.
# 2. Move the relevant VCRs from "spec/debug" to
#    "spec/fixtures/openstack/#{service}".
# 3. In these VCRs, string-replace your OpenStack's URLs/IPs by
#    "devstack.openstack.stack". Also, string-replace the used tokens by the
#    token obtained in the "common_setup.yml".
#

class OpenStackVCR
  attr_reader :service,
              :os_auth_url,
              :project_name,
              :user_id,
              :username,
              :password,
              :domain_name,
              :domain_id,
              :region,
              :region_other,
              :interface

  # This method should be called in a "before :all" call to set everything up.
  # A properly configured instance of the service class (e.g.
  # Fog::OpenStack::Volume) is then made available in @service.
  def initialize(options)
    # read arguments
    # must_be_kind_of String
    @vcr_directory = options[:vcr_directory]
    # must_be_kind_of Class
    @service_class = options[:service_class]

    # v3 by default (nil)
    @identity_version = options[:identity] == 'v2' ? 'v2' : 'v3'

    # will be used as condition
    @with_project_scope = options[:project_scoped]
    # will be used as condition
    @with_token_auth = options[:token_auth]
    # determine mode of operation
    use_recorded = !ENV.key?('OS_AUTH_URL') || ENV['USE_VCR'] == 'true'
    if use_recorded
      # when using the cassettes, there is no need to sleep in wait_for()
      Fog.interval = 0
      # use an auth URL that matches our VCR recordings (IdentityV2 for most
      # services, but IdentityV3 test obviously needs IdentityV3 auth URL)
      @os_auth_url = 'http://devstack.openstack.stack:5000'
    else
      # when an auth URL is given, we talk to a real OpenStack
      @os_auth_url = ENV['OS_AUTH_URL']
    end

    # setup VCR
    VCR.configure do |config|
      config.allow_http_connections_when_no_cassette = true
      config.hook_into :webmock

      if use_recorded
        config.cassette_library_dir = ENV['SPEC_PATH'] || @vcr_directory
        config.default_cassette_options = {:record => :none}
        config.default_cassette_options.merge! :match_requests_on => %i[method uri body]
      else
        config.cassette_library_dir = "spec/debug"
        config.default_cassette_options = {:record => :all}
      end

      config.before_playback do |interaction|
        # shift issued_at and expires_at to Time.now and Time.now + 1.day in json cassette body
        next unless interaction.response.headers["Content-Type"] == ["application/json"]

        interaction.response.body.scan(/"(issued_at|expires_at)": "(.*?)"/m).each do |match|
          time_to =
            case match[0]
            when 'issued_at' then Time.now
            when 'expires_at' then Time.now + 86400
            end

          interaction.response.body.gsub!("\"#{match[0]}\": \"#{match[1]}\"", "\"#{match[0]}\": \"#{time_to}\"")
        end
      end
    end

    # allow us to ignore dev certificates on servers
    Excon.defaults[:ssl_verify_peer] = false if ENV['SSL_VERIFY_PEER'] == 'false'

    # setup the service object
    VCR.use_cassette('common_setup') do
      Fog::OpenStack.clear_token_cache

      @region        = 'RegionOne'
      @region_other  = 'europe'
      @password      = 'password'
      @user_id       = '205e0e39a2534743b517ed0aa2fbcda7'
      @username      = 'admin'
      # keep in sync with the token obtained in the "common_setup.yml"
      @token         = '5c28403cf669414d8ee179f1e7f205ee'
      @interface     = 'admin'
      @domain_id     = 'default'
      @domain_name   = 'Default'
      @project_name  = 'admin'

      unless use_recorded
        @region        = ENV['OS_REGION_NAME']       || options[:region_name]  || @region
        @region_other  = ENV['OS_REGION_OTHER']      || options[:region_other] || @region_other
        @password      = ENV['OS_PASSWORD']          || options[:password]     || @password
        @username      = ENV['OS_USERNAME']          || options[:username]     || @username
        @user_id       = ENV['OS_USER_ID']           || options[:user_id]      || @user_id
        @token         = ENV['OS_TOKEN']             || options[:token]        || @token
        @interface     = ENV['OS_INTERFACE']         || options[:interface]    || @interface
        @domain_name   = ENV['OS_USER_DOMAIN_NAME']  || options[:domain_name]  || @domain_name
        @domain_id     = ENV['OS_USER_DOMAIN_ID']    || options[:domain_id]    || @domain_id
        @project_name  = ENV['OS_PROJECT_NAME']      || options[:project_name] || @project_name
      end

      # TODO: remove
      #   if @service_class == Fog::OpenStack::Identity::V3 || @os_auth_url.end_with?('/v3')
      if @identity_version == 'v3'
        connection_options = {
          :openstack_auth_url      => @os_auth_url,
          :openstack_region        => @region,
          :openstack_domain_name   => @domain_name,
          :openstack_endpoint_type => @interface,
          :openstack_cache_ttl     => 0
        }
        connection_options[:openstack_project_name] = @project_name if @with_project_scope
        connection_options[:openstack_service_type] = [ENV['OS_AUTH_SERVICE']] if ENV['OS_AUTH_SERVICE']
      else
        connection_options = {
          :openstack_auth_url  => @os_auth_url,
          :openstack_region    => @region,
          :openstack_tenant    => @project_name,
          :openstack_cache_ttl => 0
          # FIXME: Identity V3 not properly supported by other services yet
          # :openstack_user_domain    => ENV['OS_USER_DOMAIN_NAME']    || 'Default',
          # :openstack_project_domain => ENV['OS_PROJECT_DOMAIN_NAME'] || 'Default',
        }
      end

      if @with_token_auth
        connection_options[:openstack_auth_token] = @token
      else
        connection_options[:openstack_username] = @username
        connection_options[:openstack_api_key]  = @password
      end

      @service = @service_class.new(connection_options)
    end
  end
end
