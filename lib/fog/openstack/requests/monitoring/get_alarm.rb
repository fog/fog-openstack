module Fog
  module Monitoring
    class OpenStack
      class Real
        def get_alarm(options = {})
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "alarms/#{id}",
            :query   => options
          )
        end
      end

      class Mock
        # def get_alarm(options = {})
        #
        # end
      end
    end
  end
end
