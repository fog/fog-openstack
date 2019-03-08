require 'fog/openstack/models/collection'
require 'fog/openstack/key_manager/models/secret'

module Fog
  module OpenStack
    class KeyManager
      class Secrets < Fog::OpenStack::Collection
        model Fog::OpenStack::KeyManager::Secret

        def all(options = {})
          load_response(service.list_secrets(options), 'secrets')
        end

        def get(secret_ref)
          if secret = service.get_secret(secret_ref).body
            new(secret)
          end
        rescue Fog::OpenStack::Compute::NotFound
          nil
        end

      end
    end
  end
end
