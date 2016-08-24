require 'fog/openstack/models/model'
require 'uri'

module Fog
  module KeyManager
    class OpenStack

      class Secret < Fog::OpenStack::Model
        identity :secret_ref

        # create
        attribute :uuid
        attribute :name
        attribute :expiration
        attribute :bit_length, type: Integer
        attribute :algorithm
        attribute :mode
        attribute :secret_type
        #
        attribute :payload
        attribute :payload_content_type
        attribute :payload_content_encoding

        attribute :content_types
        attribute :created
        attribute :creator_id
        attribute :status
        attribute :updated

        def uuid
          URI(self.secret_ref).path.split('/').last
        rescue
          nil
        end

        def create
          requires :name
          merge_attributes(service.create_secret(attributes).body)
          self
        end

      end

    end
  end
end