require 'fog/openstack/models/model'

module Fog
  module OpenStack
    class Metric
      class Resource < Fog::OpenStack::Model
        identity :id

        attribute :original_resource_id
        attribute :project_id
        attribute :user_id
        attribute :metrics
      end
    end
  end
end
