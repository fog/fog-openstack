require 'test_helper'

describe "Fog::OpenStack::Network | lb_health_monitor requests" do
  before do
    @lb_health_monitor_format = {
      'id'             => String,
      'type'           => String,
      'delay'          => Integer,
      'timeout'        => Integer,
      'max_retries'    => Integer,
      'http_method'    => String,
      'url_path'       => String,
      'expected_codes' => String,
      'status'         => String,
      'admin_state_up' => Fog::Boolean,
      'tenant_id'      => String
    }
  end

  describe "success" do
    before do
      @lb_pool = network.lb_pools.create(
        :subnet_id => 'subnet_id',
        :protocol  => 'HTTP',
        :lb_method => 'ROUND_ROBIN'
      )

      type = 'PING'
      delay = 1
      timeout = 5
      max_retries = 10

      attributes = {
        :http_method    => 'GET',
        :url_path       => '/',
        :expected_codes => '200, 201',
        :admin_state_up => true,
        :tenant_id      => 'tenant_id'
      }

      @lb_health_monitor = network.create_lb_health_monitor(
        type, delay, timeout, max_retries, attributes
      ).body
    end

    after do
      @lb_pool.destroy
    end

    it "#create_lb_health_monitor" do
      @lb_health_monitor.must_match_schema('health_monitor' => @lb_health_monitor_format)
    end

    it "#list_lb_health_monitors" do
      network.list_lb_health_monitors.body.
        must_match_schema('health_monitors' => [@lb_health_monitor_format])
    end

    it "#get_lb_health_monitor" do
      lb_health_monitor_id = network.lb_health_monitors.all.first.id
      network.get_lb_health_monitor(lb_health_monitor_id).body.
        must_match_schema('health_monitor' => @lb_health_monitor_format)
    end

    it "#update_lb_health_monitor" do
      lb_health_monitor_id = network.lb_health_monitors.all.first.id
      attributes = {
        :delay          => 5,
        :timeout        => 10,
        :max_retries    => 20,
        :http_method    => 'POST',
        :url_path       => '/varz',
        :expected_codes => '200',
        :admin_state_up => false
      }

      network.update_lb_health_monitor(lb_health_monitor_id, attributes).body.
        must_match_schema('health_monitor' => @lb_health_monitor_format)
    end

    it "#associate_lb_health_monitor" do
      lb_health_monitor_id = network.lb_health_monitors.all.first.id
      network.associate_lb_health_monitor(@lb_pool.id, lb_health_monitor_id).status.must_equal 200
    end

    it "#disassociate_lb_health_monitor" do
      lb_health_monitor_id = network.lb_health_monitors.all.first.id
      network.disassociate_lb_health_monitor(@lb_pool.id, lb_health_monitor_id).status.must_equal 204
    end

    it "#delete_lb_health_monitor" do
      lb_health_monitor_id = network.lb_health_monitors.all.first.id
      network.delete_lb_health_monitor(lb_health_monitor_id).status.must_equal 204
    end
  end

  describe "failure" do
    it "#get_lb_health_monitor" do
      proc do
        network.get_lb_health_monitor(0)
      end.must_raise Fog::OpenStack::Network::NotFound
    end

    it "#update_lb_health_monitor" do
      proc do
        network.update_lb_health_monitor(0, {})
      end.must_raise Fog::OpenStack::Network::NotFound
    end

    it "#associate_lb_health_monitor" do
      proc do
        network.associate_lb_health_monitor(0, 0)
      end.must_raise Fog::OpenStack::Network::NotFound
    end

    it "#disassociate_lb_health_monitor" do
      proc do
        network.disassociate_lb_health_monitor(0, 0)
      end.must_raise Fog::OpenStack::Network::NotFound
    end

    it "#delete_lb_health_monitor" do
      proc do
        network.delete_lb_health_monitor(0)
      end.must_raise Fog::OpenStack::Network::NotFound
    end
  end
end
