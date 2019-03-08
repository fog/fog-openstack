require "test_helper"

describe "Fog::OpenStack::Metric | metric requests" do
  before do
    @metric = Fog::OpenStack::Metric.new
  end

  describe "success" do
    it "#list_resources" do
      @metric.list_resources.status.must_equal 200
    end

    it "#list_resources where type = instance_network_interface" do
      @metric.list_resources("instance_network_interface").status.must_equal 200
    end

    it "#get_resource" do
      @metric.get_resource('uuid1234').status.must_equal 200
    end

    it "#get_resource_metric_measures" do
      @metric.get_resource_metric_measures('uuid123', 'cpu_util').status.must_equal 200
    end
  end
end
