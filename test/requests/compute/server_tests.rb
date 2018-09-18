require "test_helper"

require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

describe "Fog::OpenStack::Compute | server requests" do
  def self.compute
    class_variable_get(:@@compute)
  end

  class_variable_set(:@@compute, Fog::OpenStack::Compute.new)

  def compute
    self.class.compute
  end

  describe "success" do
    before do
      @create_format = {
        'adminPass'       => String,
        'id'              => String,
        'links'           => Array,
        'security_groups' => Fog::Nullable::Array,
      }

      @base_server_format = {
        'id'           => String,
        'addresses'    => Hash,
        'flavor'       => Hash,
        'hostId'       => String,
        'metadata'     => Hash,
        'name'         => String,
        'progress'     => Integer,
        'status'       => String,
        'accessIPv4'   => Fog::Nullable::String,
        'accessIPv6'   => Fog::Nullable::String,
        'links'        => Array,
        'created'      => String,
        'updated'      => String,
        'user_id'      => String,
        'config_drive' => String,
      }

      @reservation_format = {'reservation_id' => String}

      @server_from_image_format = @base_server_format.merge('image' => Hash)

      @image_format = {
        'created'  => Fog::Nullable::String,
        'id'       => String,
        'name'     => String,
        'progress' => Fog::Nullable::Integer,
        'status'   => String,
        'updated'  => String,
        'minRam'   => Integer,
        'minDisk'  => Integer,
        'server'   => Hash,
        'metadata' => Hash,
        'links'    => Array
      }

      @image_id = get_image_ref
      @snapshot_id = nil
      @flavor_id = get_flavor_ref
      @security_group_name = get_security_group_ref

      @volume1_id = compute.create_volume('test', 'this is a test volume', 1).body["volume"]["id"]
      volume_data = {
        :delete_on_termination => true,
        :device_name           => "vda",
        :volume_id             => @volume1_id,
        :volume_size           => 1
      }

      @data = compute.create_server("test", nil, @flavor_id, "block_device_mapping" => volume_data).body['server']
      @server_id = @data['id']
    end

    it "#create_server('test', nil, #{@flavor_id}) with a block_device_mapping" do
      @data.must_match_schema(@create_format,
                              nil,
                              :allow_extra_keys     => true,
                              :allow_optional_rules => true)
    end

    it "#get_server_details(#{@server_id})" do
      compute.get_server_details(@server_id).body['server'].
        must_match_schema(@base_server_format,
                          nil,
                          :allow_extra_keys     => true,
                          :allow_optional_rules => true)
    end

    it "#block_device_mapping" do
      compute.servers.get(@server_id).volumes.first.id.must_equal @volume1_id
    end

    describe "with multiple block_device_mapping_v2" do
      before do
        @volume2_id = compute.create_volume('test', 'this is a test volume', 1).body["volume"]["id"]
        volume_data = [
          {
            :boot_index            => 0,
            :uuid                  => @volume1_id,
            :device_name           => "vda",
            :source_type           => "volume",
            :destination_type      => "volume",
            :delete_on_termination => true,
            :volume_size           => 20
          },
          {
            :boot_index            => 1,
            :uuid                  => @volume2_id,
            :device_name           => "vdb",
            :source_type           => "volume",
            :destination_type      => "volume",
            :delete_on_termination => true,
            :volume_size           => 10
          }
        ]
        data = compute.create_server("test",
                                     nil,
                                     @flavor_id,
                                     "block_device_mapping_v2" => volume_data
                                    ).body['server']
        @server_id = data['id']
      end

      it "#create_server('test', nil, #{@flavor_id})" do
        @data.must_match_schema(@create_format,
                                nil,
                                :allow_extra_keys     => true,
                                :allow_optional_rules => true)
      end

      it "#get_server_details(#{@server_id})" do
        compute.get_server_details(@server_id).body['server'].
          must_match_schema(@base_server_format,
                            nil,
                            :allow_extra_keys     => true,
                            :allow_optional_rules => true)
      end

      it "#block_device_mapping_v2" do
        #  Breaks sometimes: "Expected: ["56", "56"] <=> Actual: ["56"]"
        skip unless Minitest::Test::UNIT_TESTS_CLEAN
        compute.servers.get(@server_id).volumes.collect(&:id).sort.
          must_equal [@volume1_id, @volume2_id].sort
      end
    end

    describe "single server from image" do
      before do
        @data = compute.create_server("test", @image_id, @flavor_id).body['server']
        @server_id = @data['id']
        compute.servers.get(@server_id).wait_for { ready? } unless Fog.mocking?
        #  Fog::OpenStack::Compute.new.servers.get(@server_id).wait_for { ready? }
      end

      it "#create_server('test', #{@image_id}, 19)" do
        @data.must_match_schema(@create_format,
                                nil,
                                :allow_extra_keys     => true,
                                :allow_optional_rules => true)
      end

      it "#get_server_details(#{@server_id})" do
        compute.get_server_details(@server_id).body['server'].
          must_match_schema(@server_from_image_format,
                            nil,
                            :allow_extra_keys     => true,
                            :allow_optional_rules => true)
      end
    end

    describe "Multiple create from image" do
      before do
        @data = compute.create_server("test", @image_id, @flavor_id,
                                      "min_count" => 2, "return_reservation_id" => "True").body

        @reservation_id = @data['reservation_id']

        @multi_create_servers = []
        if Fog.mocking?
          @multi_create_servers = [Fog::Mock.random_numbers(6).to_s, Fog::Mock.random_numbers(6).to_s]
        else
          @multi_create_servers = compute.list_servers_detail(
            'reservation_id' => @reservation_id
          ).body['servers'].collect { |server| server['id'] }
        end
      end

      it "#create_server('test', @image_id , 19, {'min_count' => 2, 'return_reservation_id' => 'True'})" do
        @data.must_match_schema(@reservation_format,
                                nil,
                                :allow_extra_keys     => true,
                                :allow_optional_rules => true)
      end

      it "#validate_multi_create" do
        @multi_create_servers.size.must_equal 2
      end
    end

    # LIST
    it "#list_servers" do
      compute.list_servers.body.
        must_match_schema({'servers' => [OpenStack::Compute::Formats::SUMMARY]},
                          nil,
                          :allow_extra_keys     => true,
                          :allow_optional_rules => true)
    end

    # DETAILS
    it "#list_servers_detail" do
      compute.list_servers_detail.body["servers"][0].
        must_match_schema(@server_from_image_format,
                          nil,
                          :allow_extra_keys     => true,
                          :allow_optional_rules => true)
    end

    # CHANGE PASSWORD
    it "#change_server_password(#{@server_id}, 'fogupdatedserver')" do
      if set_password_enabled
        compute.change_server_password(@server_id, 'foggy').status.must_equal 202
        compute.servers.get(@server_id).wait_for { ready? } unless Fog.mocking?
      end
    end

    # UPDATE SERVER NAME
    it "#update_server(#{@server_id}, :name => 'fogupdatedserver')" do
      compute.update_server(@server_id, :name => 'fogupdatedserver').status.must_equal 200
      compute.servers.get(@server_id).wait_for { ready? } unless Fog.mocking?
    end

    # ADD SECURITY GROUP
    it "#add_security_group(#{@server_id}, #{@security_group_name})" do
      compute.add_security_group(@server_id, @security_group_name).status.must_equal 200
    end

    # REMOVE SECURITY GROUP
    it "#remove_security_group(#{@server_id}, #{@security_group_name})" do
      compute.remove_security_group(@server_id, @security_group_name).status.must_equal 200
    end

    describe "Create image with metadata" do
      before do
        @data = compute.create_image(@server_id, 'fog', "foo" => "bar").body
        @snapshot_id = @data['image']['id']
        # compute.images.get(@snapshot_id).wait_for { ready? }
      end

      it "#create_image(#{@server_id}, 'fog')" do
        @data.must_match_schema('image' => @image_format)
      end

      it "#rebuild_server(#{@server_id}, #{@snapshot_id}, 'fog')" do
        compute.rebuild_server(
          @server_id, @snapshot_id, 'fog', 'newpass', "foo" => "bar"
        ).body.must_match_schema({'server' => @server_from_image_format},
                                 nil,
                                 :allow_extra_keys     => true,
                                 :allow_optional_rules => true)

        compute.servers.get(@server_id).wait_for { ready? } unless Fog.mocking?
      end

      # RESIZE
      it "#resize_server(#{@server_id}, #{get_flavor_ref_resize})" do
        compute.resize_server(@server_id, get_flavor_ref_resize).status.must_equal 202
        unless Fog.mocking?
          compute.servers.get(@server_id).wait_for { state == 'VERIFY_RESIZE' }
        end
      end

      # RESIZE CONFIRM
      it "#resize_confirm(#{@server_id}, #{get_flavor_ref_resize})" do
        compute.confirm_resize_server(@server_id).status.must_equal 204
        unless Fog.mocking?
          compute.servers.get(@server_id).wait_for { ready? }
        end
      end

      # REBOOT - HARD
      it "#reboot_server(#{@server_id}, 'HARD')" do
        compute.reboot_server(@server_id, 'HARD').status.must_equal 202
        unless Fog.mocking?
          compute.servers.get(@server_id).wait_for { ready? }
        end
      end

      # REBOOT - SOFT
      it "#reboot_server(#{@server_id}, 'SOFT')" do
        compute.reboot_server(@server_id, 'SOFT').status.must_equal 202
        unless Fog.mocking?
          compute.servers.get(@server_id).wait_for { ready? }
        end
      end

      # STOP
      it "#stop_server(#{@server_id})" do
        compute.stop_server(@server_id).must_equal true
      end

      # START
      it "#start_server(#{@server_id})" do
        compute.start_server(@server_id).must_equal true
        unless Fog.mocking?
          compute.servers.get(@server_id).wait_for { ready? }
        end
      end

      it "#shelve_server(#{@server_id}" do
        compute.shelve_server(@server_id).must_equal true
        unless Fog.mocking?
          compute.servers.get(@server_id).wait_for { ready? }
        end
      end

      it "#unshelve_server(#{@server_id})" do
        compute.unshelve_server(@server_id).must_equal true
        unless Fog.mocking?
          compute.servers.get(@server_id).wait_for { ready? }
        end
      end

      # DELETE
      it "#servers.delete(#{@server_id})" do
        compute.servers.delete(@server_id)
      end

      # DELETE IMAGE
      it "#delete_image(#{@snapshot_id})" do
        Fog::OpenStack::Compute.new.servers.get(@server_id).wait_for { ready? }
        assert(compute.delete_image(@snapshot_id))
      end
    end
  end

  describe "failure" do
    it "#delete_server(0)" do
      proc do
        self.class.compute.delete_server(0)
      end.must_raise Fog::OpenStack::Compute::NotFound
    end

    it "#get_server_details(0)" do
      proc do
        self.class.compute.get_server_details(0)
      end.must_raise Fog::OpenStack::Compute::NotFound
    end

    it "#update_server(0, :name => 'fogupdatedserver', :adminPass => 'fogupdatedserver')" do
      proc do
        self.class.compute.update_server(0, :name => 'fogupdatedserver', :adminPass => 'fogupdatedserver')
      end.must_raise Fog::OpenStack::Compute::NotFound
    end

    it "#reboot_server(0)" do
      unless Fog.mocking?
        proc do
          self.class.compute.reboot_server(0)
        end.must_raise Fog::OpenStack::Compute::NotFound
      end
    end

    it "#start_server(0)" do
      unless Fog.mocking?
        proc do
          self.class.compute.start_server(0)
        end.must_raise Fog::OpenStack::Compute::NotFound
      end
    end

    it "#stop_server(0)" do
      unless Fog.mocking?
        proc do
          self.class.compute.stop_server(0)
        end.must_raise Fog::OpenStack::Compute::NotFound
      end
    end
  end
end
