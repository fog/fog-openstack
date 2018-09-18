require 'test_helper'
require 'helpers/container_infra_helper'

describe "Fog::OpenStack::ContainerInfra | bay requests" do
  before do
    @bay_format = {
      "status"              => String,
      "uuid"                => String,
      "stack_id"            => Fog::Nullable::String,
      "created_at"          => Fog::Nullable::String,
      "api_address"         => Fog::Nullable::String,
      "discovery_url"       => Fog::Nullable::String,
      "updated_at"          => Fog::Nullable::String,
      "master_count"        => Fog::Nullable::Integer,
      "coe_version"         => Fog::Nullable::String,
      "baymodel_id"         => String,
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
      @bay_model = container_infra.create_bay_model(attributes).body
      attributes = {
        :name               => "k8s",
        :baymodel_id        => @bay_model['uuid'],
        :bay_create_timeout => 1
      }

      @bay = container_infra.create_bay(attributes).body
    end

    it "#create_bay" do
      @bay.must_match_schema({"uuid" => String})
    end

    it "#list_bays" do
      container_infra.list_bays.body.must_match_schema('bays' => [@bay_format])
    end

    it "#get_bay" do
      bay_uuid = container_infra.bays.all.first.uuid
      container_infra.get_bay(bay_uuid).body.must_match_schema(@bay_format)
    end

    it "#update_bay" do
      bay_uuid = container_infra.bays.all.first.uuid
      attributes = [
         {
            "path"  => "/node_count",
            "value" => 2,
            "op"    => "replace"
         }
      ]

      container_infra.update_bay(bay_uuid, attributes).body.
        must_match_schema({"uuid" => String})
    end

    it "#delete_bay" do
      bay_uuid = container_infra.bays.all.first.uuid
      container_infra.delete_bay(bay_uuid).status.must_equal 204
    end
  end
end
