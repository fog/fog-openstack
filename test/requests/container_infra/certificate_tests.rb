require 'test_helper'
require 'helpers/container_infra_helper'

describe "Fog::OpenStack::ContainerInfra | certificate requests" do
  before do
    @certificate_format = {
      "pem"          => String,
      "bay_uuid"     => Fog::Nullable::String,
      "cluster_uuid" => Fog::Nullable::String,
      "csr"          => Fog::Nullable::String
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
      attributes = {
        :cluster_uuid => @cluster['uuid'],
        :csr      => "-----BEGIN CERTIFICATE REQUEST-----\nMIIEfzCCAmcCAQAwFDESMBAGA1UEAxMJWW91ciBOYW1lMIICIjANBgkqhkiG9w0B\n-----END CERTIFICATE REQUEST-----\n"
      }

      @certificate = container_infra.create_certificate(attributes).body
    end

    it "#create_certificate" do
      @certificate.must_match_schema(@certificate_format)
    end

    it "#get_certificate" do
      bay_uuid = container_infra.clusters.all.first.uuid
      container_infra.get_certificate(bay_uuid).body.must_match_schema(@certificate_format)
    end
  end
end
