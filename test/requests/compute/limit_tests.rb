require "test_helper"

describe "Fog::OpenStack::Compute | limits requests" do
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
      'remaining'      => Integer,
      'value'          => Integer
    }

    @absolute_limits_format = {
      'maxServerMeta'           => Integer,
      'maxTotalInstances'       => Integer,
      'maxPersonality'          => Integer,
      'maxImageMeta'            => Integer,
      'maxPersonalitySize'      => Integer,
      'maxSecurityGroupRules'   => Integer,
      'maxTotalKeypairs'        => Integer,
      'maxSecurityGroups'       => Integer,
      'maxTotalCores'           => Integer,
      'maxTotalFloatingIps'     => Integer,
      'maxTotalRAMSize'         => Integer,
      'totalCoresUsed'          => Integer,
      'totalRAMUsed'            => Integer,
      'totalInstancesUsed'      => Integer,
      'totalSecurityGroupsUsed' => Integer,
      'totalFloatingIpsUsed'    => Integer
    }

    @limits_format = {
      'rate'     => Array,
      'absolute' => Hash
    }
  end

  describe "success" do
    describe "#get_limits" do
      it "format" do
        Fog::OpenStack::Compute.new.get_limits.body['limits'].
          must_match_schema(@limits_format)
      end

      it "rate limit format" do
        Fog::OpenStack::Compute.new.get_limits.body['limits']['rate'].
          first.must_match_schema(@rate_limit_format)
      end

      it "rate limit usage format" do
        Fog::OpenStack::Compute.new.get_limits.body['limits']['rate'].
          first['limit'].first.must_match_schema(@rate_limit_usage_format)
      end

      it "absolute limits format" do
        Fog::OpenStack::Compute.new.get_limits.body['limits']['absolute'].
          must_match_schema(@absolute_limits_format)
      end
    end
  end
end
