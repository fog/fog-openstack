require "test_helper"

describe "Fog::OpenStack::Metric | metric requests" do
  before do
    @metric = Fog::OpenStack::Metric.new
  end

  describe "success" do
    it "#list_metrics" do
      @metric.list_metrics.status.must_equal 200
    end

    it "#get_metric" do
      @metric.get_metric('test').status.must_equal 200
    end

    it "#get_metric_measures" do
      @metric.get_metric_measures('metricuuid123').status.must_equal 200
    end
  end
end
