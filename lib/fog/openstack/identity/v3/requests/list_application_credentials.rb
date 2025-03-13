module Fog
    module OpenStack
      class Identity
        class V3
          class Real
            def list_application_credentials(options = {})
              user_id = options.delete('user_id') || options.delete(:user_id)
              request(
                :expects => [200],
                :method  => 'GET',
                :path    => "users/#{user_id}/application_credentials",
                :query   => options
              )
            end
          end
  
          class Mock
            def list_application_credentials(options = {})
            end
          end
        end
      end
    end
  end
