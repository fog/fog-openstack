require 'fog/openstack/models/collection'
require 'fog/openstack/container_infra/models/cluster_template'

module Fog
  module OpenStack
    class  ContainerInfra
      class ClusterTemplates < Fog::OpenStack::Collection

        model Fog::OpenStack::ContainerInfra::ClusterTemplate

        def all
          load_response(service.list_cluster_templates, 'clustertemplates')
        end

        def get(cluster_template_uuid_or_name)
          resource = service.get_cluster_template(cluster_template_uuid_or_name).body
          new(resource)
        rescue Fog::OpenStack::ContainerInfra::NotFound
          nil
        end
      end
    end
  end
end
