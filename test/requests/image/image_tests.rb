require "test_helper"

describe "Fog::OpenStack::Image | image requests" do
  before(:all) do
    openstack = Fog::OpenStack::Identity.new(:openstack_identity_api_version => 'v2.0')

    @image_attributes = {
      :name             => 'new image',
      :owner            => openstack.current_tenant['id'],
      :is_public        => true,
      :copy_from        => 'http://website.com/image.iso',
      :disk_format      => 'iso',
      :properties       => {
        :user_id  => openstack.current_user['id'],
        :owner_id => openstack.current_tenant['id']
      },
      :container_format => 'bare'
    }

    @image_format = {
      'name'             => String,
      'container_format' => String,
      'disk_format'      => String,
      'checksum'         => String,
      'id'               => String,
      'size'             => Integer
    }

    @detailed_image_format = {
      'id'               => String,
      'name'             => String,
      'size'             => Integer,
      'disk_format'      => String,
      'container_format' => String,
      'checksum'         => String,
      'min_disk'         => Integer,
      'created_at'       => String,
      'deleted_at'       => Fog::Nullable::String,
      'updated_at'       => String,
      'deleted'          => Fog::Boolean,
      'protected'        => Fog::Boolean,
      'is_public'        => Fog::Boolean,
      'status'           => String,
      'min_ram'          => Integer,
      'owner'            => Fog::Nullable::String,
      'properties'       => Hash
    }

    @image_meta_format = {
      'X-Image-Meta-Is_public'           => String,
      'X-Image-Meta-Min_disk'            => Fog::Nullable::String,
      'X-Image-Meta-Property-Ramdisk_id' => Fog::Nullable::String,
      'X-Image-Meta-Disk_format'         => Fog::Nullable::String,
      'X-Image-Meta-Created_at'          => String,
      'X-Image-Meta-Container_format'    => Fog::Nullable::String,
      'Etag'                             => String,
      'Location'                         => String,
      'X-Image-Meta-Protected'           => String,
      'Date'                             => String,
      'X-Image-Meta-Name'                => String,
      'X-Image-Meta-Min_ram'             => String,
      'Content-Type'                     => String,
      'X-Image-Meta-Updated_at'          => String,
      'X-Image-Meta-Property-Kernel_id'  => Fog::Nullable::String,
      'X-Image-Meta-Size'                => String,
      'X-Image-Meta-Checksum'            => Fog::Nullable::String,
      'X-Image-Meta-Deleted'             => String,
      'Content-Length'                   => String,
      'X-Image-Meta-Status'              => String,
      'X-Image-Meta-Owner'               => String,
      'X-Image-Meta-Id'                  => String
    }

    @image_members_format = [
      {
        'can_share' => Fog::Nullable::Boolean,
        'member_id' => String
      }
    ]

    if Fog.mocking?
      image_attributes = @image_attributes
    else
      require 'tempfile'
      image_attributes = @image_attributes.dup
      image_attributes.delete(:copy_from)
      @test_iso = Tempfile.new(['fog_test_iso', '.iso'])
      @test_iso.write Fog::Mock.random_hex(32)
      @test_iso.close
      image_attributes[:location] = @test_iso.path
    end

    @instance = Fog::OpenStack::Image.new.create_image(image_attributes).body
  end

  after do
    @test_iso.delete if @test_iso
  end

  describe "success" do
    it "#list_public_images" do
      Fog::OpenStack::Image.new.list_public_images.body.must_match_schema('images' => [@image_format])
    end

    it "#list_public_images_detailed" do
      Fog::OpenStack::Image.new.list_public_images_detailed.body.
        must_match_schema('images' => [@detailed_image_format])
    end

    it "#create_image" do
      @instance.must_match_schema('image' => @detailed_image_format)
    end

    it "#get_image" do
      Fog::OpenStack::Image.new.get_image(@instance['image']['id']).headers.
        must_match_schema(@image_meta_format)
    end

    it "#update_image" do
      Fog::OpenStack::Image.new.update_image(
        :id   => @instance['image']['id'],
        :name => 'edit image'
      ).body['image'].must_match_schema(@detailed_image_format)
    end

    it "#add_member_to_image" do
      [200, 204].must_include(
        Fog::OpenStack::Image.new.add_member_to_image(
          @instance['image']['id'], @instance['image']['owner']
        ).status
      )
    end

    it "#get_image_members" do
      [200, 204].must_include(Fog::OpenStack::Image.new.get_image_members(@instance['image']['id']).status)
    end

    it "#get_shared_images" do
      [200, 204].must_include(Fog::OpenStack::Image.new.get_shared_images(@instance['image']['owner']).status)
    end

    it "#remove_member_from_image" do
      [200, 204].must_include(
        Fog::OpenStack::Image.new.remove_member_from_image(
          @instance['image']['id'], @instance['image']['owner']
        ).status
      )
    end

    it "#delete_image" do
      Fog::OpenStack::Image.new.delete_image(@instance['image']['id']).status.must_equal 200
    end
  end
end
