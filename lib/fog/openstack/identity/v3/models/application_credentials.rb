require 'fog/openstack/models/collection'
require 'fog/openstack/identity/v3/models/os_credential'

module Fog
  module OpenStack
    class Identity
      class V3
        class ApplicationCredentials < Fog::OpenStack::Collection
          model Fog::OpenStack::Identity::V3::ApplicationCredential

          def all(options = {})
            load_response(service.list_application_credentials(options), 'credentials')
          end

          def find_by_id(id)
            cached_credential = find { |credential| credential.id == id }
            return cached_credential if cached_credential
            credential_hash = service.get_os_credential(id).body['credential']
            Fog::OpenStack::Identity::V3::Credential.new(
              credential_hash.merge(:service => service)
            )
          end

          def destroy(id)
            credential = find_by_id(id)
            credential.destroy
          end
        end
      end
    end
  end
end
