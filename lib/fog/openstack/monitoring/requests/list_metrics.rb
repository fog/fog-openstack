module Fog
  module OpenStack
    class Monitoring
      class Real
        def list_metrics(options = {})
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "metrics",
            :query   => options
          )
        end
      end

      class Mock
        # def list_metrics(options = {})
        #
        # end
      end
    end
  end
end
