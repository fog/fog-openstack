require "test_helper"

describe "Fog::Metric::OpenStack | metric requests" do
  before do
    @metric = Fog::Metric::OpenStack.new
  end

  describe "success" do
    it "#list_resources" do
      @metric.list_resources.status.must_equal 200
    end

    it "#get_resource" do
      @metric.get_resource('uuid1234').status.must_equal 200
    end

    it "#get_resource_metric_measures" do
      @metric.get_resource_metric_measures('uuid123', 'cpu_util').status.must_equal 200
    end
  end
end
