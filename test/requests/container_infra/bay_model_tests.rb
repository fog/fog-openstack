require 'test_helper'
require 'helpers/container_infra_helper'

describe "Fog::OpenStack::ContainerInfra | bay model requests" do
  before do
    @bay_model_format = {
      "insecure_registry"     => Fog::Nullable::String,
      "http_proxy"            => Fog::Nullable::String,
      "updated_at"            => Fog::Nullable::String,
      "floating_ip_enabled"   => Fog::Nullable::Boolean,
      "fixed_subnet"          => Fog::Nullable::String,
      "master_flavor_id"      => Fog::Nullable::String,
      "uuid"                  => Fog::Nullable::String,
      "no_proxy"              => Fog::Nullable::String,
      "https_proxy"           => Fog::Nullable::String,
      "tls_disabled"          => Fog::Nullable::Boolean,
      "keypair_id"            => String,
      "public"                => Fog::Nullable::Boolean,
      "labels"                => Fog::Nullable::Hash,
      "docker_volume_size"    => Fog::Nullable::Integer,
      "server_type"           => Fog::Nullable::String,
      "external_network_id"   => Fog::Nullable::String,
      "cluster_distro"        => Fog::Nullable::String,
      "image_id"              => Fog::Nullable::String,
      "volume_driver"         => Fog::Nullable::String,
      "registry_enabled"      => Fog::Nullable::Boolean,
      "docker_storage_driver" => Fog::Nullable::String,
      "apiserver_port"        => Fog::Nullable::Integer,
      "name"                  => String,
      "created_at"            => Fog::Nullable::String,
      "network_driver"        => Fog::Nullable::String,
      "fixed_network"         => Fog::Nullable::String,
      "coe"                   => Fog::Nullable::String,
      "flavor_id"             => Fog::Nullable::String,
      "master_lb_enabled"     => Fog::Nullable::Boolean,
      "dns_nameserver"        => Fog::Nullable::String
    }
  end

  describe "success" do
    before do
      attributes = {
        :tls_disabled          => true,
        :keypair_id            => "kp",
        :server_type           => "vm",
        :external_network_id   => "public",
        :image_id              => "fedora-atomic-latest",
        :name                  => "k8s-bm2",
        :coe                   => "kubernetes",
        :flavor_id             => "m1.small",
        :docker_volume_size    => 3
      }

      @bay = container_infra.create_bay_model(attributes).body
    end

    it "#create_bay_model" do
      @bay.must_match_schema(@bay_model_format)
    end

    it "#list_bay_models" do
      container_infra.list_bay_models.body.must_match_schema('baymodels' => [@bay_model_format])
    end

    it "#get_bay_model" do
      bay_model_uuid = container_infra.bay_models.all.first.uuid
      container_infra.get_bay_model(bay_model_uuid).body.must_match_schema(@bay_model_format)
    end

    it "#update_bay_model" do
      bay_model_uuid = container_infra.bay_models.all.first.uuid
      attributes = [
        {
          "path"  => "/master_lb_enabled",
          "value" => "True",
          "op"    => "replace"
        },
        {
          "path"  => "/registry_enabled",
          "value" => "True",
          "op"    => "replace"
        }
      ]

      container_infra.update_bay_model(bay_model_uuid, attributes).body.
        must_match_schema(@bay_model_format)
    end

    it "#delete_bay_model" do
      bay_model_uuid = container_infra.bay_models.all.first.uuid
      container_infra.delete_bay_model(bay_model_uuid).status.must_equal 204
    end
  end
end
