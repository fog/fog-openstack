require "test_helper"

describe "Fog::Compute[:openstack] | limits requests" do
  before do
    @rate_limit_format = {
      'regex' => String,
      'uri'   => String,
      'limit' => Array
    }

    @rate_limit_usage_format = {
      'next-available' => String,
      'unit'           => String,
      'verb'           => String,
      'remaining'      => Fixnum,
      'value'          => Fixnum
    }

    @absolute_limits_format = {
      'maxServerMeta'           => Fixnum,
      'maxTotalInstances'       => Fixnum,
      'maxPersonality'          => Fixnum,
      'maxImageMeta'            => Fixnum,
      'maxPersonalitySize'      => Fixnum,
      'maxSecurityGroupRules'   => Fixnum,
      'maxTotalKeypairs'        => Fixnum,
      'maxSecurityGroups'       => Fixnum,
      'maxTotalCores'           => Fixnum,
      'maxTotalFloatingIps'     => Fixnum,
      'maxTotalRAMSize'         => Fixnum,
      'totalCoresUsed'          => Fixnum,
      'totalRAMUsed'            => Fixnum,
      'totalInstancesUsed'      => Fixnum,
      'totalSecurityGroupsUsed' => Fixnum,
      'totalFloatingIpsUsed'    => Fixnum
    }

    @limits_format = {
      'rate'     => Array,
      'absolute' => Hash
    }
  end

  describe "success" do
    describe "#get_limits" do
      it "format" do
        Fog::Compute[:openstack].get_limits.body['limits'].
          must_match_schema(@limits_format)
      end

      it "rate limit format" do
        Fog::Compute[:openstack].get_limits.body['limits']['rate'].
          first.must_match_schema(@rate_limit_format)
      end

      it "rate limit usage format" do
        Fog::Compute[:openstack].get_limits.body['limits']['rate'].
          first['limit'].first.must_match_schema(@rate_limit_usage_format)
      end

      it "absolute limits format" do
        Fog::Compute[:openstack].get_limits.body['limits']['absolute'].
          must_match_schema(@absolute_limits_format)
      end
    end
  end
end
