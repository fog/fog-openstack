module Fog
    module OpenStack
      class Identity
        class V3
          class Real
            def create_application_credentials(credential = {})
              user_id = credential.delete('user_id') || credential.delete(:user_id)
              puts Fog::JSON.encode(:application_credential => credential)
              request(
                :expects => [201],
                :method  => 'POST',
                :path    => "users/#{user_id}/application_credentials",
                :body    => Fog::JSON.encode(:application_credential => credential)
              )
            end
          end
  
          class Mock
          end
        end
      end
    end
  end
