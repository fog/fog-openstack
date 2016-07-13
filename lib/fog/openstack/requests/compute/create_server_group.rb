module Fog
  module Compute
    class OpenStack
      class Real
        def create_server_group(name, policy)
          Fog::Compute::OpenStack::ServerGroup.validate_server_group_policy policy

          body = { 'server_group' => {
            'name' => name,
            'policies' => [policy]
          }}
          rsp = request(
            :body     => Fog::JSON.encode(body),
            :expects  => 200,
            :method   => 'POST',
            :path     => 'os-server-groups'
          )
        end
      end

      class Mock
        def create_server_group(name, policy)
          Fog::Compute::OpenStack::ServerGroup.validate_server_group_policy policy

          response = Excon::Response.new
          response.status = 200
          response.headers = {
            "Content-Type" => "text/html; charset=UTF-8",
            "Content-Length" => "0",
            "Date" => Date.new
          }
          response.body = { 'server_group' => {
            'id'         => '1234',
            'name'       => name,
            'policies'   => [ policy ],
            'members'    => [],
            'metadata'   => {},
            'project_id' => 'test-project',
            'user_id'    => 'test-user'
          } }
          response
        end
      end
    end
  end
end
