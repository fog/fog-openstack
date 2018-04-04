require "test_helper"

describe "Fog::Compute[:openstack] | availability zone requests" do
  before do
    @flavor_format = {
      'zoneName'  => String,
      'hosts'     => Fog::Nullable::Hash,
      'zoneState' => Hash
    }
  end

  describe "success" do
    it "#list_zones" do
      Fog::Compute[:openstack].list_zones.body.
        must_match_schema('availabilityZoneInfo' => [@flavor_format])
    end

    it "#list_zones_detailed" do
      Fog::Compute[:openstack].list_zones_detailed.body.
        must_match_schema('availabilityZoneInfo' => [@flavor_format])
    end
  end
end
