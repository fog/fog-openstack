require 'fog/openstack/models/collection'
require 'fog/openstack/models/volume_v1/backup'
require 'fog/openstack/models/volume/backups'

module Fog
  module Volume
    class OpenStack
      class V1
        class Backups < Fog::OpenStack::Collection
          model Fog::Volume::OpenStack::V1::Backup
          include Fog::Volume::OpenStack::Backups
        end
      end
    end
  end
end
