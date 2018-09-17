require "test_helper"
require "helpers/network_helper"

describe "Fog::OpenStack::Network | lb_vip" do
  describe "success" do
    before do
      attributes = {
        :subnet_id           => 'subnet_id',
        :pool_id             => 'pool_id',
        :protocol            => 'HTTP',
        :protocol_port       => 80,
        :name                => 'test-vip',
        :description         => 'Test VIP',
        :address             => '10.0.0.1',
        :session_persistence => {
          "cookie_name" => "COOKIE_NAME",
          "type"        => "APP_COOKIE"
        },
        :connection_limit    => 10,
        :admin_state_up      => true,
        :tenant_id           => 'tenant_id'
      }

      @instance = network.lb_vips.create(attributes)
    end

    after do
      @instance.destroy.must_equal true
    end

    it "#create" do
      @instance.id.wont_be_nil
    end

    it "#update" do
      @instance.pool_id = 'new_pool_id'
      @instance.name = 'new-test-vip'
      @instance.description = 'New Test VIP'
      @instance.session_persistence = {"type" => "HTTP_COOKIE"}
      @instance.connection_limit = 5
      @instance.admin_state_up = false
      @instance.update.status.must_equal "ACTIVE"
    end
  end
end
