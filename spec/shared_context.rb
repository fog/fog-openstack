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
  attr_reader :service, :os_auth_url, :project_name
  # This method should be called in a "before :all" call to set everything up.
  # A properly configured instance of the service class (e.g.
  # Fog::Volume::OpenStack) is then made available in @service.
  def initialize(options)
    # read arguments
    # must_be_kind_of String
    @vcr_directory = options[:vcr_directory]
    # must_be_kind_of Class
    @service_class = options[:service_class]
    # determine mode of operation
    use_recorded = !ENV.key?('OS_AUTH_URL') || ENV['USE_VCR'] == 'true'
    if use_recorded
      # when using the cassettes, there is no need to sleep in wait_for()
      Fog.interval = 0
      # use an auth URL that matches our VCR recordings (IdentityV2 for most
      # services, but IdentityV3 test obviously needs IdentityV3 auth URL)
      @os_auth_url = if [Fog::Identity::OpenStack::V3,
                         Fog::Volume::OpenStack,
                         Fog::Volume::OpenStack::V1,
                         Fog::Volume::OpenStack::V2,
                         Fog::Image::OpenStack,
                         Fog::Image::OpenStack::V1,
                         Fog::Network::OpenStack].include? @service_class
                       'http://devstack.openstack.stack:5000/v3'
                     else
                       'http://devstack.openstack.stack:5000/v2.0'
                     end
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
        config.default_cassette_options.merge! :match_requests_on => [:method, :uri, :body]
      else
        config.cassette_library_dir = "spec/debug"
        config.default_cassette_options = {:record => :all}
      end
    end

    # allow us to ignore dev certificates on servers
    Excon.defaults[:ssl_verify_peer] = false if ENV['SSL_VERIFY_PEER'] == 'false'

    # setup the service object
    VCR.use_cassette('common_setup') do
      Fog::OpenStack.clear_token_cache

      region        = 'RegionOne'
      password      = 'password'
      username      = 'admin'
      domain_name   = 'Default'
      @project_name = 'admin'

      unless use_recorded
        region        = ENV['OS_REGION_NAME']       || options[:region_name]  || region
        password      = ENV['OS_PASSWORD']          || options[:password]     || password
        username      = ENV['OS_USERNAME']          || options[:username]     || username
        domain_name   = ENV['OS_USER_DOMAIN_NAME']  || options[:domain_name]  || domain_name
        @project_name = ENV['OS_PROJECT_NAME']      || options[:project_name] || @project_name
      end

      if @service_class == Fog::Identity::OpenStack::V3 || @os_auth_url.end_with?('/v3')
        connection_options = {
          :openstack_auth_url    => "#{@os_auth_url}/auth/tokens",
          :openstack_region      => region,
          :openstack_api_key     => password,
          :openstack_username    => username,
          :openstack_domain_name => domain_name,
          :openstack_cache_ttl   => 0
        }
        connection_options[:openstack_project_name] = @project_name if options[:project_scoped]
        connection_options[:openstack_service_type] = [ENV['OS_AUTH_SERVICE']] if ENV['OS_AUTH_SERVICE']
      else
        connection_options = {
          :openstack_auth_url  => "#{@os_auth_url}/tokens",
          :openstack_region    => region,
          :openstack_api_key   => password,
          :openstack_username  => username,
          :openstack_tenant    => @project_name,
          :openstack_cache_ttl => 0
          # FIXME: Identity V3 not properly supported by other services yet
          # :openstack_user_domain    => ENV['OS_USER_DOMAIN_NAME']    || 'Default',
          # :openstack_project_domain => ENV['OS_PROJECT_DOMAIN_NAME'] || 'Default',
        }
      end
      @service = @service_class.new(connection_options)
    end
  end
end
