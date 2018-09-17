require "test_helper"

require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

# With Minitest the use of class variable is one way of providing before(:all)
# Meanwhile using class variable using @@<name> triggers a cascade of messages
# such as "warning: class variable access from toplevel" which pollute the tests
# output. The latter has been avoided using class_variable_set/get and class
# methods to wrap them.
describe "Fog::OpenStack::Compute | address requests" do
  def self.compute
    class_variable_get(:@@compute)
  end

  def self.server_id
    class_variable_get(:@@server_id)
  end

  def self.data
    class_variable_get(:@@data)
  end

  class_variable_set(:@@compute, Fog::OpenStack::Compute.new)
  class_variable_set(:@@server_id,
                     compute.create_server("test_server",
                                           get_image_ref,
                                           get_flavor_ref).body['server']['id'])
  class_variable_set(:@@data, compute.allocate_address.body)

  compute.servers.get(server_id).wait_for { ready? }

  def compute
    self.class.compute
  end

  MiniTest::Unit.after_tests do
    compute.delete_server(server_id)
  end

  describe "success" do
    def address_id
      self.class.data['floating_ip']['id']
    end

    def address_ip
      self.class.data['floating_ip']['ip']
    end

    def address_format
      {
        "instance_id" => NilClass,
        "ip"          => String,
        "fixed_ip"    => NilClass,
        "id"          => Integer,
        "pool"        => String
      }
    end

    def address_pools_format
      {"name" => String}
    end

    it "#allocate_address" do
      self.class.data.must_match_schema("floating_ip" => address_format)
    end

    it "#list_all_addresses" do
      compute.list_all_addresses.body.
        must_match_schema("floating_ips" => [address_format])
    end

    it "#get_address(address_id)" do
      compute.get_address(address_id).body.
        must_match_schema("floating_ip" => address_format)
    end

    it "#list_address_pools" do
      compute.list_address_pools.body.
        must_match_schema("floating_ip_pools" => [address_pools_format])
    end

    it "#associate_address(server_id, ip_address)" do
      compute.associate_address(self.class.server_id, address_ip).body.must_equal ""
    end

    it "#disassociate_address(server_id, ip_address)" do
      compute.disassociate_address(self.class.server_id, address_ip).body.must_equal ""
    end

    it "#release_address(ip_address)" do
      compute.release_address(address_id).status.must_equal 202
    end
  end
end
