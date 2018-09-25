require 'fog/core'
require 'fog/json'

module Fog
  # Monkey patch to reflect https://github.com/fog/fog-core/commit/06b7ab4
  # needed because fog-core 2.1.1+ implies entire namespace change
  # is only availabe from fog-openstack 1.0.0+
  module Attributes
    module InstanceMethods
      def all_attributes
        self.class.attributes.reduce({}) do |hash, attribute|
          if masks[attribute].nil?
            Fog::Logger.deprecation("Please define #{attribute} using the Fog DSL")
            hash[attribute] = send(attribute)
          else
            hash[masks[attribute]] = send(attribute)
          end

          hash
        end
      end

      def all_associations
        self.class.associations.keys.reduce({}) do |hash, association|
          if masks[association].nil?
            Fog::Logger.deprecation("Please define #{association} using the Fog DSL")
            hash[association] = associations[association] || send(association)
          else
            hash[masks[association]] = associations[association] || send(association)
          end

          hash
        end
      end
    end
  end

  module Baremetal
    autoload :OpenStack, 'fog/baremetal/openstack'
  end

  module Compute
    autoload :OpenStack, 'fog/compute/openstack'
  end

  module ContainerInfra
    autoload :OpenStack, 'fog/container_infra/openstack'
  end

  module DNS
    autoload :OpenStack, 'fog/dns/openstack'
  end

  module Event
    autoload :OpenStack, 'fog/event/openstack'
  end

  module Identity
    autoload :OpenStack, 'fog/identity/openstack'
  end

  module Image
    autoload :OpenStack, 'fog/image/openstack'
  end

  module Introspection
    autoload :OpenStack, 'fog/introspection/openstack'
  end

  module KeyManager
    autoload :OpenStack, 'fog/key_manager/openstack'
  end

  module Metering
    autoload :OpenStack, 'fog/metering/openstack'
  end

  module Metric
    autoload :OpenStack, 'fog/metric/openstack'
  end

  module Monitoring
    autoload :OpenStack, 'fog/monitoring/openstack'
  end

  module Network
    autoload :OpenStack, 'fog/network/openstack'
  end

  module NFV
    autoload :OpenStack, 'fog/nfv/openstack'
  end

  module Orchestration
    autoload :OpenStack, 'fog/orchestration/openstack'
    autoload :Util, 'fog/orchestration/util/recursive_hot_file_loader'
  end

  module SharedFileSystem
    autoload :OpenStack, 'fog/shared_file_system/openstack'
  end

  module Storage
    autoload :OpenStack, 'fog/storage/openstack'
  end

  module Volume
    autoload :OpenStack, 'fog/volume/openstack'
  end

  module Workflow
    autoload :OpenStack, 'fog/workflow/openstack'

    class OpenStack
      autoload :V2, 'fog/workflow/openstack/v2'
    end
  end

  module OpenStack
    require 'fog/openstack/auth/token'

    autoload :VERSION, 'fog/openstack/version'

    autoload :Core, 'fog/openstack/core'
    autoload :Errors, 'fog/openstack/errors'
    autoload :Planning, 'fog/planning/openstack'

    extend Fog::Provider

    service(:baremetal,          'Baremetal')
    service(:compute,            'Compute')
    service(:container_infra,    'ContainerInfra')
    service(:dns,                'DNS')
    service(:event,              'Event')
    service(:identity,           'Identity')
    service(:image,              'Image')
    service(:introspection,      'Introspection')
    service(:key,                'KeyManager')
    service(:metering,           'Metering')
    service(:metric,             'Metric')
    service(:monitoring,         'Monitoring')
    service(:network,            'Network')
    service(:nfv,                'NFV')
    service(:orchestration,      'Orchestration')
    service(:planning,           'Planning')
    service(:shared_file_system, 'SharedFileSystem')
    service(:storage,            'Storage')
    service(:volume,             'Volume')
    service(:workflow,           'Workflow')

    @token_cache = {}

    class << self
      attr_accessor :token_cache
    end

    def self.clear_token_cache
      Fog::OpenStack.token_cache = {}
    end

    def self.endpoint_region?(endpoint, region)
      region.nil? || endpoint['region'] == region
    end

    def self.get_supported_version(supported_versions, uri, auth_token, connection_options = {})
      supported_version = get_version(supported_versions, uri, auth_token, connection_options)
      version = supported_version['id'] if supported_version
      version_raise(supported_versions) if version.nil?

      version
    end

    def self.get_supported_version_path(supported_versions, uri, auth_token, connection_options = {})
      supported_version = get_version(supported_versions, uri, auth_token, connection_options)
      link = supported_version['links'].find { |l| l['rel'] == 'self' } if supported_version
      path = URI.parse(link['href']).path if link
      version_raise(supported_versions) if path.nil?

      path.chomp '/'
    end

    def self.get_supported_microversion(supported_versions, uri, auth_token, connection_options = {})
      supported_version = get_version(supported_versions, uri, auth_token, connection_options)
      supported_version['version'] if supported_version
    end

    # CGI.escape, but without special treatment on spaces
    def self.escape(str, extra_exclude_chars = '')
      str.gsub(/([^a-zA-Z0-9_.-#{extra_exclude_chars}]+)/) do
        '%' + $1.unpack('H2' * $1.bytesize).join('%').upcase
      end
    end

    def self.get_version(supported_versions, uri, auth_token, connection_options = {})
      version_cache = "#{uri}#{supported_versions}"
      return @version[version_cache] if @version && @version[version_cache]

      # To allow version discovery we need a "version less" endpoint
      path = uri.path.gsub(/\/v([1-9]+\d*)(\.[1-9]+\d*)*.*$/, '/')
      url = "#{uri.scheme}://#{uri.host}:#{uri.port}#{path}"
      connection = Fog::Core::Connection.new(url, false, connection_options)
      response = connection.request(
        :expects => [200, 204, 300],
        :headers => {'Content-Type' => 'application/json',
                     'Accept'       => 'application/json',
                     'X-Auth-Token' => auth_token},
        :method  => 'GET'
      )

      body = Fog::JSON.decode(response.body)

      @version                = {} unless @version
      @version[version_cache] = extract_version_from_body(body, supported_versions)
    end

    def self.extract_version_from_body(body, supported_versions)
      versions = []
      unless body['versions'].nil? || body['versions'].empty?
        versions = body['versions'].kind_of?(Array) ? body['versions'] : body['versions']['values']
      end
      # Some version API would return single endpoint rather than endpoints list, try to get it via 'version'.
      unless body['version'].nil? or versions.length != 0
        versions = [body['version']]
      end
      version = nil

      # order is important, preferred status should be first
      %w(CURRENT stable SUPPORTED DEPRECATED).each do |status|
        version = versions.find { |x| x['id'].match(supported_versions) && (x['status'] == status) }
        break if version
      end

      version
    end

    def self.version_raise(supported_versions)
      raise Fog::OpenStack::Errors::ServiceUnavailable,
            "OpenStack service only supports API versions #{supported_versions.inspect}"
    end
  end
end
