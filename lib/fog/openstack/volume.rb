module Fog
  module OpenStack
    class Volume < Fog::Service
      autoload :V1, 'fog/openstack/volume/v1'
      autoload :V2, 'fog/openstack/volume/v2'
      autoload :V3, 'fog/openstack/volume/v3'

      @@recognizes = [:openstack_auth_token, :openstack_management_url,
                      :persistent, :openstack_service_type, :openstack_service_name,
                      :openstack_tenant, :openstack_tenant_id,
                      :openstack_api_key, :openstack_username, :openstack_identity_endpoint,
                      :current_user, :current_tenant, :openstack_region,
                      :openstack_endpoint_type, :openstack_cache_ttl,
                      :openstack_project_name, :openstack_project_id,
                      :openstack_project_domain, :openstack_user_domain, :openstack_domain_name,
                      :openstack_project_domain_id, :openstack_user_domain_id, :openstack_domain_id,
                      :openstack_identity_api_version]

      # Fog::OpenStack::Volume.new() will return a Fog::OpenStack::Volume::V3 or a Fog::OpenStack::Volume::V2 or a
      #  Fog::OpenStack::Volume::V1, choosing the V3 by default, as V2 is deprecated since OpenStackWallaby and V1 is
      #  deprecated since OpenStack Juno
      def self.new(args = {})
        @openstack_auth_uri = URI.parse(args[:openstack_auth_url]) if args[:openstack_auth_url]
        return super unless inspect == 'Fog::OpenStack::Volume'

        # Each version resolves a different catalog entry: "volumev3", "volumev2"
        # and "volume" respectively. Try them newest first and move on when the
        # catalog does not advertise one, re-raising when none of them match.
        last_error = nil
        [V3, V2, V1].each do |version|
          return version.new(args)
        rescue Fog::OpenStack::Auth::Catalog::ServiceTypeError => e
          last_error = e
        end
        raise last_error
      end
    end
  end
end
