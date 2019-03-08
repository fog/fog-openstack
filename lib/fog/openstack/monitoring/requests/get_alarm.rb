module Fog
  module OpenStack
    class Monitoring
      class Real
        def get_alarm(id)
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "alarms/#{id}"
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
