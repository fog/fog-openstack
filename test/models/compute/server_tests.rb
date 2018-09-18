require "test_helper"

describe "Fog::OpenStack::Compute | server" do
  let (:compute) { Fog::OpenStack::Compute.new }

  describe "success" do
    it "#floating_ips" do
      flavor = compute.flavors.first.id
      image  = compute.images.first.id
      server = compute.servers.new(
        :name       => 'test server',
        :flavor_ref => flavor,
        :image_ref  => image
      )
      server.save

      ip1 = Fog::OpenStack::Network.new.floating_ips.create(
        :floating_network_id => 'f0000000-0000-0000-0000-000000000000',
        :fixed_ip_address    => '192.168.11.3'
      )

      server.associate_address(ip1.fixed_ip_address)
      server.reload
      server.floating_ip_addresses.must_equal(["192.168.11.3"])
    end

    describe "#security_groups" do
      let(:my_group) do
        compute.security_groups.create(
          :name        => 'my_group',
          :description => 'my group'
        )
      end

      let(:flavor) { compute.flavors.first.id }
      let(:image)  { compute.images.first.id }

      let(:server) do
        server = compute.servers.new(
          :name       => 'test server',
          :flavor_ref => flavor,
          :image_ref  => image
          )

        server.security_groups = my_group
        server.save
        server
      end

      let (:found_groups) { server.security_groups }
      let (:group) { found_groups.first }

      after do
        unless Fog.mocking?
          server.destroy if server

          begin
            compute.servers.get(server.id).wait_for { false }
          rescue Fog::Errors::Error
            # ignore, server went away
          end
        end
        my_group.destroy if my_group
      end

      it "groups size" do
        found_groups.length.must_equal 1
      end

      it "name" do
        group.name.must_equal 'my_group'
      end

      it "" do
        group.service.must_equal server.service
      end
    end

    describe "#server" do
      let(:flavor) { compute.flavors.first.id }
      let(:image) { compute.images.first.id }

      it "creates server" do
        server = compute.servers.new(
          :name       => 'test server',
          :flavor_ref => flavor,
          :image_ref  => image,
          :state      => 'success'
        )
        server.failed?.must_equal false
      end

      it "fails server creation" do
        server = compute.servers.new(
          :name       => 'test server',
          :flavor_ref => flavor,
          :image_ref  => image,
          :state      => 'ERROR'
        )
        server.failed?.must_equal true
      end
    end

    describe "#metadata" do
      after do
        unless Fog.mocking?
          server.destroy if server

          begin
            compute.servers.get(server.id).wait_for { false }
          rescue Fog::Errors::Error
            # ignore, server went away
          end
        end
      end

      it "does" do
        flavor = compute.flavors.first.id
        image  = compute.images.first.id

        server = compute.servers.new(
          :name       => 'test server',
          :metadata   => {"foo" => "bar"},
          :flavor_ref => flavor,
          :image_ref  => image
        )

        server.save

        server.metadata.length.must_equal 1

        server.metadata.each do |datum|
          datum.value = 'foo'
          datum.save
          datum.destroy
        end
      end
    end

    it "#resize" do
      flavor = compute.flavors.first.id
      image  = compute.images.first.id

      server = compute.servers.new(
        :name       => 'test server',
        :flavor_ref => flavor,
        :image_ref  => image
      )

      server.save

      flavor_resize = compute.flavors[1].id
      server.resize(flavor_resize)
      server.wait_for { server.state == "VERIFY_RESIZE" } unless Fog.mocking?
      server.revert_resize
      server.wait_for { server.state == "ACTIVE" } unless Fog.mocking?
      server.resize(flavor_resize)
      server.wait_for { server.state == "VERIFY_RESIZE" } unless Fog.mocking?
      server.confirm_resize

      unless Fog.mocking?
        server.destroy if server

        begin
          compute.servers.get(server.id).wait_for { false }
        rescue Fog::Errors::Error
          # ignore, server went away
        end
      end
    end

    describe "#volumes" do
      let(:volume) do
        volume = compute.volumes.new(
          :name        => 'test volume',
          :description => 'test volume',
          :size        => 1
        )
        volume.save
        volume.wait_for { volume.status == 'available' } unless Fog.mocking?
        volume
      end

      let(:server) do
        flavor = compute.flavors.first.id
        image  = compute.images.first.id
        server = compute.servers.new(
          :name       => 'test server',
          :flavor_ref => flavor,
          :image_ref  => image
        )

        server.save
        server.wait_for { server.state == "ACTIVE" } unless Fog.mocking?
        server.attach_volume(volume.id, '/dev/vdc')
        server
      end

      let(:volumes) do
        volume.wait_for { volume.status == 'in-use' } unless Fog.mocking?
        server.volumes
      end

      let(:volume_attachments) { server.volume_attachments }

      after do
        unless Fog.mocking?
          server.destroy if server
          volume.destroy if volume

          begin
            compute.servers.get(server.id).wait_for { false }
            compute.volumes.get(volume.id).wait_for { false }
          rescue Fog::Errors::Error
            # ignore, server went away
          end
        end
      end

      it "volume size" do
        volumes.length.must_equal 1
      end

      it "name" do
        volumes.first.name.must_equal 'test volume'
      end

      it "volume_attachments size" do
        volume_attachments.length.must_equal 1
      end

      it "volume_attachments device" do
        attachment = volume_attachments.first
        attachment['device'].must_equal '/dev/vdc'
      end

      describe "detach volume" do
        before do
          server.detach_volume(volume.id)
          volume.wait_for { volume.status == 'available' } unless Fog.mocking?
        end

        it "has no volumes" do
          found_volumes = server.volumes
          found_volumes.length.must_equal 0
        end

        it "has no volume_attachments" do
          found_attachments = server.volume_attachments
          found_attachments.length.must_equal 0
        end
      end
    end
  end
end
