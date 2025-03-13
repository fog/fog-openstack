require 'fog/openstack/models/model'

module Fog
  module OpenStack
    class Identity
      class V3
        class ApplicationCredential < Fog::OpenStack::Model
          identity :id

          attribute :description
          attribute :name
          attribute :roles
          attribute :expires_at
          attribute :user_id

          class << self
            attr_accessor :cache
          end

          @cache = {}

          def to_s
            name
          end

          def destroy
            clear_cache
            requires :id
            service.delete_project(id)
            true
          end

          def update(attr = nil)
            clear_cache
            requires :id
            merge_attributes(
              service.update_project(id, attr || attributes).body['project']
            )
            self
          end

          def create
            merge_attributes(
              service.create_application_credentials(attributes).body['application_credential']
            )
            self
          end
        end
      end
    end
  end
end
