require "test_helper"
require "helpers/network_helper"

describe "Fog::OpenStack::Network | lb_health_monitor" do
  describe "success" do
    before do
      @lb_pool = network.lb_pools.create(
        :subnet_id => 'subnet_id',
        :protocol  => 'HTTP',
        :lb_method => 'ROUND_ROBIN'
      )

      @instance = network.lb_health_monitors.create(
        :type           => 'PING',
        :delay          => 1,
        :timeout        => 5,
        :max_retries    => 10,
        :http_method    => 'GET',
        :url_path       => '/',
        :expected_codes => '200, 201',
        :admin_state_up => true,
        :tenant_id      => 'tenant_id'
      )
    end

    after do
      @lb_pool.destroy
    end

    it "#create" do
      @instance.id.wont_be_nil
    end

    it "#update" do
      @instance.delay = 5
      @instance.timeout = 10
      @instance.max_retries = 20
      @instance.http_method = 'POST'
      @instance.url_path = '/varz'
      @instance.expected_codes = '200'
      @instance.admin_state_up = false
      @instance.update.expected_codes.must_equal "200"
    end

    it "#associate_to_pool" do
      @instance.associate_to_pool(@lb_pool.id).must_equal true
    end

    it "#disassociate_from_pool" do
      @instance.disassociate_from_pool(@lb_pool.id).must_equal true
    end

    it "#destroy" do
      @instance.destroy.must_equal true
    end
  end
end
