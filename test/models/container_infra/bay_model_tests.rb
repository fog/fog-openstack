require "test_helper"
require 'helpers/container_infra_helper'

describe "Fog::OpenStack::ContainerInfra | bay model" do
  describe "success" do
    before do
      @instance = container_infra.bay_models.create(
        :tls_disabled          => true,
        :keypair_id            => "kp",
        :external_network_id   => "public",
        :image_id              => "fedora-atomic-latest",
        :name                  => "k8s-bm2",
        :coe                   => "kubernetes",
        :flavor_id             => "m1.small",
        :docker_volume_size    => 3
      )
    end

    it "#create" do
      @instance.uuid.wont_be_nil
    end

    it "#update" do
      @instance.name                 = 'rename-test-bay-model'
      @instance.update.name.must_equal 'rename-test-bay-model'
    end

    it "#destroy" do
      @instance.destroy.must_equal true
    end
  end
end
