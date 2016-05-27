require 'fog/openstack/models/collection'
require 'fog/openstack/models/monitoring/metric'

module Fog
  module Monitoring
    class OpenStack
      class Metrics < Fog::OpenStack::Collection
        model Fog::Monitoring::OpenStack::Metric

        def all(options = {})
          load_response(service.list_metrics(options), 'elements')
        end

        def list_metric_names(options = {})
          load_response(service.list_metric_names(options), 'elements')
        end

        def create(attributes)
          super(attributes)
        end

        def create_metric_array(metrics_list = [])
          service.create_metric_array(metrics_list)
        end
      end
    end
  end
end
