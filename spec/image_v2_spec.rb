require 'spec_helper'
require_relative './shared_context'

describe Fog::Image::OpenStack do
  spec_data_folder = 'spec/fixtures/openstack/image_v2'

  before :all do
    openstack_vcr = OpenStackVCR.new(
      :vcr_directory => spec_data_folder,
      :service_class => Fog::Image::OpenStack # Fog to choose latest available version
    )
    @service = openstack_vcr.service
  end

  def cleanup_image(image, image_name = nil, image_id = nil)
    # Delete the image
    image.destroy if image
    image_by_id = @service.images.find_by_id(image_id) rescue false if image_id
    image_by_id.destroy if image_by_id
    if image_name
      @service.images.all(:name => image_name).each(&:destroy)
    end
    # Check that the deletion worked
    proc { @service.images.find_by_id image_id }.must_raise Fog::Image::OpenStack::NotFound if image_id
    @service.images.all(:name => image_name).length.must_equal 0 if image_name
  end

  it "CRUD & list images" do
    VCR.use_cassette('image_v2_crud') do
      image_name = 'foobar'
      image_rename = 'baz'

      @service.images.all.wont_equal nil
      begin
        # Create an image called foobar
        foobar_image = @service.images.create(:name => image_name)
        foobar_id = foobar_image.id
        @service.images.all(:name => image_name).length.must_equal 1
        foobar_image.status.must_equal 'queued'

        # Rename it to baz
        # see "Patch images" test below - for now this will be a simple synthesis of a JSON patch with op = 'replace'
        foobar_image.update(:name => image_rename)

        foobar_image.name.must_equal image_rename
        baz_image = @service.images.find_by_id foobar_id
        baz_image.wont_equal nil
        baz_image.id.must_equal foobar_id
        baz_image.name.must_equal image_rename

        # Read the image freshly by listing images filtered by the new name
        images = @service.images.all(:name => image_rename)
        images.length.must_equal 1
        images.first.id.must_equal baz_image.id

      ensure
        cleanup_image baz_image
        @service.images.all.select { |image| [image_name, image_rename].include? image.name }.each(&:destroy)
        # Check that the deletion worked
        @service.images.all.count { |image| [image_name, image_rename].include? image.name }.must_equal 0
      end
    end
  end

  it "Image creation with ID" do
    VCR.use_cassette('image_v2_create_id') do
      image_name = 'foobar_id'

      # Here be dragons - highly recommend not to supply an ID when creating
      begin
        # increment this identifier when running test more than once, unless the VCR recording is being used
        identifier = '11111111-2222-3333-aaaa-bbbbbbcccce1'

        # Create an image with a specified ID
        foobar_image = @service.images.create(:name => 'foobar_id', :id => identifier)
        foobar_id = foobar_image.id
        @service.images.all(:name => image_name).length.must_equal 1
        foobar_image.status.must_equal 'queued'
        foobar_id.must_equal identifier

        get_image = @service.images.find_by_id(identifier)
        get_image.name.must_equal image_name

      ensure
        cleanup_image foobar_image, image_name, foobar_id
      end
    end
  end

  it "Image creation with specified location" do
    VCR.use_cassette('image_v2_create_location') do
      begin
        # Create image with location of image data
        skip "Figure out 'Create image with location of image data'"
      end
    end
  end

  it "Image upload & download in bulk" do
    VCR.use_cassette('image_v2_upload_download') do
      image_name = 'foobar_up1'
      begin
        # minimal.ova is a "no-op" virtual machine image, 80kB .ova file containing 64Mb dynamic disk
        image_path = "#{spec_data_folder}/minimal.ova"

        foobar_image = @service.images.create(:name             => image_name,
                                              :container_format => 'ovf',
                                              :disk_format      => 'vmdk'
                                             )
        foobar_id = foobar_image.id

        # Status should be queued
        @service.images.find_by_id(foobar_id).status.must_match(/queued/)

        # Upload data from File or IO object
        foobar_image.upload_data File.new(image_path, 'r')

        # Status should be saving or active
        @service.images.find_by_id(foobar_id).status.must_match(/saving|active/)

        # Get an IO object from which to download image data - wait until finished saving though
        while @service.images.find_by_id(foobar_id).status == 'saving'
          sleep 1
        end
        @service.images.find_by_id(foobar_id).status.must_equal 'active'

        # Bulk download
        downloaded_data = foobar_image.download_data
        downloaded_data.size.must_equal File.size(image_path)

      ensure
        cleanup_image foobar_image, image_name
      end
    end
  end

  it "Deactivates and activates an image" do
    VCR.use_cassette('image_v2_activation') do
      image_name = 'foobar3a'
      # "no-op" virtual machine image, 80kB .ova file containing 64Mb dynamic disk
      image_path = "spec/fixtures/openstack/image_v2/minimal.ova"

      begin
        # Create an image called foobar2
        foobar_image = @service.images.create(:name             => image_name,
                                              :container_format => 'ovf',
                                              :disk_format      => 'vmdk'
                                             )
        foobar_id = foobar_image.id
        foobar_image.upload_data File.new(image_path, 'r')
        while @service.images.find_by_id(foobar_id).status == 'saving'
          sleep 1
        end

        foobar_image.deactivate
        proc { foobar_image.download_data }.must_raise Excon::Errors::Forbidden

        foobar_image.reactivate
        foobar_image.download_data
      ensure
        cleanup_image foobar_image, image_name
      end
    end
  end

  it "Adds and deletes image tags" do
    VCR.use_cassette('image_v2_tags') do
      image_name = 'foobar3'
      begin
        # Create an image
        foobar_image = @service.images.create(:name             => image_name,
                                              :container_format => 'ovf',
                                              :disk_format      => 'vmdk'
                                             )
        foobar_id = foobar_image.id

        foobar_image.add_tag 'tag1'
        @service.images.find_by_id(foobar_id).tags.must_include 'tag1'

        foobar_image.add_tags %w(tag2 tag3 tag4)
        @service.images.find_by_id(foobar_id).tags.must_equal %w(tag4 tag1 tag2 tag3)

        foobar_image.remove_tag 'tag2'
        @service.images.find_by_id(foobar_id).tags.must_equal %w(tag4 tag1 tag3)

        foobar_image.remove_tags %w(tag1 tag3)
        @service.images.find_by_id(foobar_id).tags.must_include 'tag4'

      ensure
        cleanup_image foobar_image, image_name
      end
    end
  end

  it "CRUD and list image members" do
    VCR.use_cassette('image_v2_member_crudl') do
      image_name = 'foobar4'
      tenant_id = 'tenant1'
      begin
        # Create an image called foobar
        foobar_image = @service.images.create(:name => image_name)

        foobar_image.members.size.must_equal 0
        foobar_image.add_member tenant_id
        foobar_image.members.size.must_equal 1

        member = foobar_image.member tenant_id
        member.wont_equal nil
        member['status'].must_equal 'pending'

        member['status'] = 'accepted'
        foobar_image.update_member member
        foobar_image.member(tenant_id)['status'].must_equal 'accepted'

        foobar_image.remove_member member['member_id']
        foobar_image.members.size.must_equal 0
      ensure
        cleanup_image foobar_image, image_name
      end
    end
  end

  it "Gets JSON schemas for 'images', 'image', 'members', 'member'" do
    VCR.use_cassette('image_v2_schemas') do
      skip 'Fetching JSON schemas: to be implemented'
    end
  end

  it "CRUD resource types" do
    VCR.use_cassette('image_v2_resource_type_crud') do
      skip 'CRUD resource types: to be implemented'
    end
  end

  it "CRUD namespace metadata definition" do
    VCR.use_cassette('image_v2_namespace_metadata_crud') do
      skip 'CRUD namespace metadata definition: to be implemented'
    end
  end

  it "CRUD property metadata definition" do
    VCR.use_cassette('image_v2_property_metadata_crud') do
      skip 'CRUD property metadata definition: to be implemented'
    end
  end

  it "CRUD object metadata definition" do
    VCR.use_cassette('image_v2_object_metadata_crud') do
      skip 'CRUD object metadata definition: to be implemented'
    end
  end

  it "CRUD tag metadata definition" do
    VCR.use_cassette('image_v2_tag_metadata_crud') do
      skip 'CRUD tag metadata definition: to be implemented'
    end
  end

  it "CRUD schema metadata definition" do
    VCR.use_cassette('image_v2_schema_metadata_crud') do
      skip 'CRUD schema metadata definition: to be implemented'
    end
  end

  it "Creates, lists & gets tasks" do
    VCR.use_cassette('image_v2_task_clg') do
      skip 'Creates, lists & gets tasks: to be implemented'
    end
  end
end
