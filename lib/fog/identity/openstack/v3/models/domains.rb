require 'fog/openstack/models/collection'
require 'fog/identity/openstack/v3/models/domain'

module Fog
  module Identity
    class OpenStack
      class V3
        class Domains < Fog::OpenStack::Collection
          model Fog::Identity::OpenStack::V3::Domain

          def all(options = {})
            cache = Fog::Identity::OpenStack::V3::Domain.cache
            cached_domain, expires = cache[{:token => service.auth_token, :options => options}]
            return cached_domain if cached_domain && expires > Time.now
            domain_to_cache = load_response(service.list_domains(options), 'domains')

            cache[{:token => service.auth_token, :options => options}] = domain_to_cache, Time.now + 30 # 30-second TTL
            Fog::Identity::OpenStack::V3::Domain.cache = cache
            domain_to_cache
          end

          def create(attributes)
            super(attributes)
          end

          def auth_domains(options = {})
            load(service.auth_domains(options).body['domains'])
          end

          def find_by_id(id)
            cache = Fog::Identity::OpenStack::V3::Domain.cache
            cached_domain, expires = cache[{:token => service.auth_token, :id => id}]
            return cached_domain if cached_domain && expires > Time.now
            domain_hash = service.get_domain(id).body['domain']
            domain_to_cache = Fog::Identity::OpenStack::V3::Domain.new(
              domain_hash.merge(:service => service)
            )
            cache[{:token => service.auth_token, :id => id}] = domain_to_cache, Time.now + 30 # 30-second TTL
            Fog::Identity::OpenStack::V3::Domain.cache = cache
            domain_to_cache
          end

          def destroy(id)
            domain = find_by_id(id)
            domain.destroy
          end
        end
      end
    end
  end
end
