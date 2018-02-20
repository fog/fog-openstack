module Fog
  module Identity
    class OpenStack
      class V3 < Fog::Service
        class Mock
          include Fog::OpenStack::Core
          def initialize(options = {})
          end
        end
      end
    end
  end
end
