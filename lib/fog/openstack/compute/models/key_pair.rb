require 'fog/openstack/models/model'

module Fog
  module OpenStack
    class Compute
      class KeyPair < Fog::OpenStack::Model
        identity  :name

        attribute :fingerprint
        attribute :public_key
        attribute :private_key
        attribute :user_id
        attribute :id

        attr_accessor :public_key

        def destroy
          requires :name

          service.delete_key_pair(name)
          true
        end

        def save
          requires :name

          data = if public_key
                   service.create_key_pair(name, public_key, user_id).body['keypair']
                 else
                   service.create_key_pair(name, nil, user_id).body['keypair']
                 end
          new_attributes = data.select { |key, _value| ['fingerprint', 'public_key', 'name', 'private_key', 'user_id'].include?(key) }
          merge_attributes(new_attributes)
          true
        end

        def write(path = "#{ENV['HOME']}/.ssh/fog_#{Fog.credential}_#{name}.pem")
          if writable?
            split_private_key = private_key.split(/\n/)
            File.open(path, "w") do |f|
              split_private_key.each { |line| f.puts line }
              f.chmod 0o600
            end
            "Key file built: #{path}"
          else
            "Invalid private key"
          end
        end

        def writable?
          !!(private_key && ENV.key?('HOME'))
        end
      end
    end
  end
end