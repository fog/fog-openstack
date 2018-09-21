require "test_helper"
require 'helpers/container_infra_helper'

describe "Fog::OpenStack::ContainerInfra | certificate" do
  describe "success" do
    before do
      @instance = container_infra.certificates.create(
        :bay_uuid => '0562d357-8641-4759-8fed-8173f02c9633',
        :csr          => "-----BEGIN CERTIFICATE REQUEST-----\nMIIEfzCCAmcCAQAwFDESMBAGA1UEAxMJWW91ciBOYW1lMIICIjANBgkqhkiG9w0B\n-----END CERTIFICATE REQUEST-----\n"
      )
    end

    it "#create" do
      @instance.pem.wont_be_nil
    end

    it "#get" do
      @instance = container_infra.certificates.get("0562d357-8641-4759-8fed-8173f02c9633")
      @instance.pem.wont_be_nil
    end
  end
end
