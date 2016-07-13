module Fog
  module Compute
    class OpenStack
      class Real
        def get_server_group(group_id)
          request(
            :expects  => 200,
            :method   => 'GET',
            :path     => "/os-server-groups/#{group_id}"
          )
        end
      end

      class Mock
        def get_server_group(group_id)
          response = Excon::Response.new
          response.status = 200
          response.body = {
            'server_group' => {
              'id' => group_id,
              'name' => 'test-server-group',
              'policies' => [ 'anti-affinity' ],
              'members' => [],
              'project_id' => 'test-project',
              'user_id' => 'test-user'
            }
          }
          response
        end
      end
    end
  end
end
