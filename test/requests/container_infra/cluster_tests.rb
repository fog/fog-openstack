require 'test_helper'
require 'helpers/container_infra_helper'

describe "Fog::OpenStack::ContainerInfra | cluster requests" do
  before do
    @cluster_format = {
      "status"              => String,
      "uuid"                => String,
      "stack_id"            => Fog::Nullable::String,
      "created_at"          => Fog::Nullable::String,
      "api_address"         => Fog::Nullable::String,
      "discovery_url"       => Fog::Nullable::String,
      "updated_at"          => Fog::Nullable::String,
      "master_count"        => Fog::Nullable::Integer,
      "coe_version"         => Fog::Nullable::String,
      "cluster_template_id" => String,
      "master_addresses"    => Fog::Nullable::Array,
      "node_count"          => Fog::Nullable::Integer,
      "node_addresses"      => Fog::Nullable::Array,
      "status_reason"       => Fog::Nullable::String,
      "create_timeout"      => Fog::Nullable::Integer,
      "name"                => String
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
      attributes = {
        :name                => "k8s",
        :cluster_template_id => @cluster_template['uuid'],
        :create_timeout => 1
      }

      @cluster = container_infra.create_cluster(attributes).body
    end

    it "#create_cluster" do
      @cluster.must_match_schema("uuid" => String)
    end

    it "#list_clusters" do
      container_infra.list_clusters.body.must_match_schema('clusters' => [@cluster_format])
    end

    it "#get_cluster" do
      cluster_uuid = container_infra.clusters.all.first.uuid
      container_infra.get_cluster(cluster_uuid).body.must_match_schema(@cluster_format)
    end

    it "#update_cluster" do
      cluster_uuid = container_infra.clusters.all.first.uuid
      attributes = [
        {
          "path"  => "/node_count",
          "value" => 2,
          "op"    => "replace"
        }
      ]

      container_infra.update_cluster(cluster_uuid, attributes).body.
        must_match_schema({"uuid" => String})
    end

    it "#delete_cluster" do
      cluster_uuid = container_infra.clusters.all.first.uuid
      container_infra.delete_cluster(cluster_uuid).status.must_equal 204
    end
  end
end
