require 'test_helper'
require 'helpers/container_infra_helper'

@cluster_templates = []

describe "Fog::OpenStack::ContainerInfra | cluster template requests" do
  before do
    @cluster_template_format = {
      "insecure_registry"     => Fog::Nullable::String,
      "http_proxy"            => Fog::Nullable::String,
      "updated_at"            => Fog::Nullable::String,
      "floating_ip_enabled"   => Fog::Boolean,
      "fixed_subnet"          => Fog::Nullable::String,
      "master_flavor_id"      => Fog::Nullable::String,
      "uuid"                  => Fog::Nullable::String,
      "no_proxy"              => Fog::Nullable::String,
      "https_proxy"           => Fog::Nullable::String,
      "tls_disabled"          => Fog::Boolean,
      "keypair_id"            => String,
      "public"                => Fog::Boolean,
      "labels"                => Fog::Nullable::Hash,
      "docker_volume_size"    => Integer,
      "server_type"           => String,
      "external_network_id"   => String,
      "cluster_distro"        => String,
      "image_id"              => String,
      "volume_driver"         => String,
      "registry_enabled"      => Fog::Nullable::Boolean,
      "docker_storage_driver" => String,
      "apiserver_port"        => Fog::Nullable::Integer,
      "name"                  => String,
      "created_at"            => Fog::Nullable::String,
      "network_driver"        => String,
      "fixed_network"         => Fog::Nullable::String,
      "coe"                   => String,
      "flavor_id"             => String,
      "master_lb_enabled"     => Fog::Boolean,
      "dns_nameserver"        => String
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
      @cluster_template = container_infra.create_cluster_template(attributes).body
    end

    it "#create_cluster_template" do
      @cluster_template.must_match_schema("uuid" => String)
    end

    it "#list_cluster_templates" do
      container_infra.list_cluster_templates.body.must_match_schema('clustertemplates' => [@cluster_template_format])
    end

    it "#get_cluster_template" do
      cluster_template_uuid = container_infra.cluster_templates.all.first.uuid
      container_infra.get_cluster_template(cluster_template_uuid).body.must_match_schema(@cluster_template_format)
    end

    it "#update_cluster_template" do
      cluster_template_uuid = container_infra.cluster_templates.all.first.uuid
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

      container_infra.update_cluster_template(cluster_template_uuid, attributes).body.
        must_match_schema(@cluster_template_format)
    end

    it "#delete_cluster_template" do
      cluster_template_uuid = container_infra.cluster_templates.all.first.uuid
      container_infra.delete_cluster_template(cluster_template_uuid).status.must_equal 204
    end
  end
end
