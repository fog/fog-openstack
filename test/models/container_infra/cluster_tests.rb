require "test_helper"
require 'helpers/container_infra_helper'

describe "Fog::OpenStack::ContainerInfra | cluster" do
  describe "success" do
    before do
      @instance = container_infra.clusters.create(
        :name                      => "test-cluster",
        :cluster_template_id       => "0562d357-8641-4759-8fed-8173f02c9633"
      )
    end

    it "#create" do
      @instance.uuid.wont_be_nil
    end

    it "#update" do
      @instance.name                 = 'rename-test-cluster'
      @instance.update.name.must_equal "rename-test-cluster"
    end

    it "#destroy" do
      @instance.destroy.must_equal true
    end
  end
end
