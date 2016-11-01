module Fog
  module Identity
    class OpenStack
      class V3 < Fog::Service
        class Mock
          include Fog::OpenStack::Core
          def initialize(options = {})
          end
        end

        def self.get_api_version(uri, connection_options = {})
          connection = Fog::Core::Connection.new(uri, false, connection_options)
          response = connection.request(:expects => [200],
                                        :headers => {'Content-Type' => 'application/json',
                                                     'Accept'       => 'application/json'},
                                        :method  => 'GET')

          body = Fog::JSON.decode(response.body)
          version = nil
          unless body['version'].empty?
            version = body['version']['id']
          end
          if version.nil?
            raise Fog::OpenStack::Errors::ServiceUnavailable, "No version available at #{uri}"
          end

          version
        end
      end
    end
  end
end
