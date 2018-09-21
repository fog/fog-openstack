module Minitest
  class Test
    def self.container_infra
      class_variable_get(:@@container_infra)
    end

    class_variable_set(:@@container_infra, Fog::ContainerInfra::OpenStack.new)
  end
end

def container_infra
  self.class.container_infra
end
