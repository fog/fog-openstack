require 'test_helper'

describe "Fog::OpenStack::Network | lb_vip requests" do
  describe "success" do
    before do
      @lb_vip_format = {
        'id'                  => String,
        'subnet_id'           => String,
        'pool_id'             => String,
        'protocol'            => String,
        'protocol_port'       => Integer,
        'name'                => String,
        'description'         => String,
        'address'             => String,
        'port_id'             => String,
        'session_persistence' => Hash,
        'connection_limit'    => Integer,
        'status'              => String,
        'admin_state_up'      => Fog::Boolean,
        'tenant_id'           => String
      }
      subnet_id = "subnet_id"
      pool_id = "pool_id"
      protocol = 'HTTP'
      protocol_port = 80
      attributes = {
        :name                => 'test-vip',
        :description         => 'Test VIP',
        :address             => '10.0.0.1',
        :connection_limit    => 10,
        :session_persistence => {"cookie_name" => "COOKIE_NAME", "type" => "APP_COOKIE"},
        :admin_state_up      => true,
        :tenant_id           => 'tenant_id'
      }
      @lb_vip =  network.create_lb_vip(subnet_id, pool_id, protocol, protocol_port, attributes).body
      @lb_vip_id = @lb_vip["vip"]["id"]
    end

    it "#create_lb_vip" do
      @lb_vip.must_match_schema('vip' => @lb_vip_format)
    end

    it "#list_lb_vips" do
      network.list_lb_vips.body.must_match_schema('vips' => [@lb_vip_format])
    end

    it "#get_lb_vip" do
      lb_vip_id = network.lb_vips.all.first.id
      network.get_lb_vip(lb_vip_id).body.
        must_match_schema('vip' => @lb_vip_format)
    end

    it "#update_lb_vip" do
      lb_vip_id = network.lb_vips.all.first.id
      attributes = {
        :pool_id             => "new_pool_id",
        :name                => "new-test-vip",
        :description         => "New Test VIP",
        :connection_limit    => 5,
        :session_persistence => {"type" => "HTTP_COOKIE"},
        :admin_state_up      => false
      }
      network.update_lb_vip(lb_vip_id, attributes).body.
        must_match_schema('vip' => @lb_vip_format)
    end

    it "#delete_lb_vip" do
      lb_vip_id = network.lb_vips.all.first.id
      network.delete_lb_vip(lb_vip_id).status.must_equal 204
    end
  end

  describe "failure" do
    it "#get_lb_vip" do
      proc do
        network.get_lb_vip(0)
      end.must_raise Fog::OpenStack::Network::NotFound
    end

    it "#update_lb_vip" do
      proc do
        network.update_lb_vip(0, {})
      end.must_raise Fog::OpenStack::Network::NotFound
    end

    it "#delete_lb_vip" do
      proc do
        network.delete_lb_vip(0)
      end.must_raise Fog::OpenStack::Network::NotFound
    end
  end
end
