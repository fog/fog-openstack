module Fog
  module OpenStack
    class Orchestration
      class Real
        def show_stack_details(name, id)
          request(
            method: 'GET',
            path: "stacks/#{name}/#{id}",
            expects: 200
          )
        end
      end

      class Mock
        def show_stack_details(_name, id)
          stack = data[:stacks][id]
          raise Fog::OpenStack::Orchestration::NotFound if stack.nil?

          Excon::Response.new(
            body: { 'stack' => stack.values },
            status: 200
          )
        end
      end
    end
  end
end
