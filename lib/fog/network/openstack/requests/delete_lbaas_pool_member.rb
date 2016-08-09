module Fog
  module Network
    class OpenStack
      class Real
        def delete_lbaas_pool_member(pool_id, member_id)
          request(
            :expects => 204,
            :method  => 'DELETE',
            :path    => "lbaas/pools/#{pool_id}/members/#{member_id}"
          )
        end
      end

      class Mock
        def delete_lbaas_pool_member(member_id)
          response = Excon::Response.new
          if list_lb_members.body['members'].map { |r| r['id'] }.include? member_id
            data[:lb_members].delete(member_id)
            response.status = 204
            response
          else
            raise Fog::Network::OpenStack::NotFound
          end
        end
      end
    end
  end
end
