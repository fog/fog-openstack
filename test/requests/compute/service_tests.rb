require "test_helper"

describe "Shindo.tests('Fog::Compute[:openstack] | service requests" do
  before do
    @service_format = {
      "id"              => Integer,
      "binary"          => String,
      "host"            => String,
      "state"           => String,
      "status"          => String,
      "updated_at"      => String,
      "zone"            => String,
      'disabled_reason' => Fog::Nullable::String
    }
    @services = Fog::Compute[:openstack].list_services.body
    @service = @services['services'].last
  end

  describe "success" do
    it "#list_services" do
      @services.must_match_schema('services' => [@service_format])
    end

    it "#disable_service" do
      Fog::Compute[:openstack].disable_service(
        @service['host'], @service['binary']
      ).body["service"]["status"].must_equal "disabled"
    end

    it "#disable_service_log_reason" do
      disabled_service = Fog::Compute[:openstack].disable_service_log_reason(
        @service['host'], @service['binary'], 'reason'
      ).body
      disabled_service["service"]["status"].must_equal "disabled"
      disabled_service["service"]["disabled_reason"].must_equal "test2"
    end

    it "#enable_service" do
      Fog::Compute[:openstack].enable_service(
        @service['host'], @service['binary']
      ).body["service"]["status"].must_equal "enabled"
    end
  end
end
