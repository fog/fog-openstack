module Minitest
  class Test
    def self.network
      class_variable_get(:@@network)
    end

    class_variable_set(:@@network, Fog::Network[:openstack])
  end
end

def network
  self.class.network
end
