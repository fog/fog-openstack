module Fog
  module KeyManager
    class OpenStack
      class Real
        def get_secret_acl(uuid)
          request(
              :expects => [200],
              :method  => 'GET',
              :path    => "secrets/#{uuid}/acl",
          )
        end
        
	      def get_container_acl(uuid)
          request(
              :expects => [200],
              :method  => 'GET',
              :path    => "containers/#{uuid}/acl",
          )
        end

      end

      class Mock

        def get_secret_acl(_uuid)
          response = Excon::Response.new
          response.status = 200
          response.body = {
              "data" => {
                  "body" =>
                      {
                          "read"=>
                              {
                                  "project-access"=>false,
                                  "updated"=>"2017-04-25T19:10:52",
                                  "users"=>["45895d3a393f42b2a8760f5dafa9c6d8", "dc2cb4f0d30044e2b0251409c94cc955"],
                                  "created"=>"2017-04-25T19:10:52"}
                      }
              }
          }
          response
        end

        def get_container_acl(_uuid)
          response = Excon::Response.new
          response.status = 200
          response.body = {
              "data" => {
                  "body" =>
                      {
                          "read"=>
                              {
                                  "project-access"=>true,
                                  "updated"=>"2017-04-25T19:10:52",
                                  "users"=>["45895d3a393f42b2a8760f5dafa9c6d8"],
                                  "created"=>"2017-04-25T19:10:52"}
                      }
              }
          }

          response
        end

        end
    end
  end
end
