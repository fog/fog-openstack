require 'fog/openstack/models/model'
require 'uri'

module Fog
  module KeyManager
    class OpenStack

      class Secret < Fog::OpenStack::Model
        identity :secret_ref

        attribute :uuid
        attribute :algorithm
        attribute :bit_length
        attribute :content_types
        attribute :created
        attribute :creator_id
        attribute :expiration
        attribute :mode
        attribute :name
        attribute :secret_type
        attribute :status
        attribute :updated

        def uuid
          URI(self.secret_ref).path.split('/').last
        rescue
          nil
        end

      end

    end
  end
end