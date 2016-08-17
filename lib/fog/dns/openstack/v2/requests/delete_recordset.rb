module Fog
  module DNS
    class OpenStack
      class V2
        class Real
          def delete_recordset(zone_id, id)
            request(
              :expects => 202,
              :method  => 'DELETE',
              :path    => "zones/#{zone_id}/recordsets/#{id}"
            )
          end
        end

        class Mock
          def delete_recordset(zone_id, id)
            response = Excon::Response.new
            response.status = 202

            recordset                  = data[:recordset_updated] || data[:recordsets]["recordsets"].first.dup
            recordset["zone_id"]       = zone_id
            recordset["id"]            = id
            recordset["status"]        = "PENDING"
            recordset["action"]        = "DELETE"
            recordset["links"]["self"] = "https://127.0.0.1:9001/v2/zones/#{zone_id}/recordsets/#{id}"

            response.body = recordset
            response
          end
        end
      end
    end
  end
end
