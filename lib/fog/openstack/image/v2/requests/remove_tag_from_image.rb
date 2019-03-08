module Fog
  module OpenStack
    class Image
      class V2
        class Real
          def remove_tag_from_image(image_id, tag)
            request(
              :expects => [204],
              :method  => 'DELETE',
              :path    => "images/#{image_id}/tags/#{tag}"
            )
          end
        end

        class Mock
          def remove_tag_from_image(_image_id, _tag)
            response = Excon::Response.new
            response.status = 204
            response
          end
        end
      end
    end
  end
end
