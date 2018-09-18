require "test_helper"

describe "Fog::OpenStack::Metering | meter requests" do
  before do
    @metering = Fog::OpenStack::Metering.new

    @sample_format = {
      'counter_name'      => String,
      'user_id'           => String,
      'resource_id'       => String,
      'timestamp'         => String,
      'resource_metadata' => Hash,
      'source'            => String,
      'counter_unit'      => String,
      'counter_volume'    => Float,
      'project_id'        => String,
      'message_id'        => String,
      'counter_type'      => String
    }

    @meter_format = {
      'user_id'     => String,
      'name'        => String,
      'resource_id' => String,
      'project_id'  => String,
      'type'        => String,
      'unit'        => String
    }

    @statistics_format = {
      'count'          => Integer,
      'duration_start' => String,
      'min'            => Float,
      'max'            => Float,
      'duration_end'   => String,
      'period'         => Integer,
      'period_end'     => String,
      'duration'       => Float,
      'period_start'   => String,
      'avg'            => Float,
      'sum'            => Float
    }
  end

  describe "success" do
    it "#list_meters" do
      @metering.list_meters.body.must_match_schema([@meter_format])
    end

    it "#get_samples" do
      @metering.get_samples('test').body.must_match_schema([@sample_format])
    end

    it "#get_statistics" do
      @metering.get_statistics('test').body.must_match_schema([@statistics_format])
    end
  end
end
