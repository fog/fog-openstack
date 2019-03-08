require 'fog/openstack/models/collection'
require 'fog/openstack/storage/models/directory'

module Fog
  module OpenStack
    class Storage
      class Directories < Fog::OpenStack::Collection
        model Fog::OpenStack::Storage::Directory

        def all(options = {})
          data = service.get_containers(options)
          load_response(data)
        end

        def get(key, options = {})
          data = service.get_container(key, options)
          directory = new(key: key)
          data.headers.each do |l_key, value|
            if ['X-Container-Bytes-Used', 'X-Container-Object-Count'].include?(l_key)
              directory.merge_attributes(l_key => value)
            end
          end
          directory.files.merge_attributes(options)
          directory.files.instance_variable_set(:@loaded, true)

          data.body.each do |file|
            directory.files << directory.files.new(file)
          end
          directory
        rescue Fog::OpenStack::Storage::NotFound
          nil
        end
      end
    end
  end
end
