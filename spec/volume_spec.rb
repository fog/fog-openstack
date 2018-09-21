require 'spec_helper'
require_relative './shared_context'

[
  Fog::OpenStack::Volume,
  Fog::OpenStack::Volume::V1,
  Fog::OpenStack::Volume::V2
].delete_if { |the_class| ENV['TEST_CLASS'] && ENV['TEST_CLASS'] != the_class.name }.each do |service_class|
  describe service_class do
    before :all do
      vcr_directory = 'spec/fixtures/openstack/volume' if service_class == Fog::OpenStack::Volume
      vcr_directory = 'spec/fixtures/openstack/volume_v1' if service_class == Fog::OpenStack::Volume::V1
      vcr_directory = 'spec/fixtures/openstack/volume_v2' if service_class == Fog::OpenStack::Volume::V2

      openstack_vcr = OpenStackVCR.new(
        :vcr_directory => vcr_directory,
        :service_class => service_class
      )
      @service           = openstack_vcr.service
      @os_auth_url       = openstack_vcr.os_auth_url

      # Account for the different parameter naming between v1 and v2 services
      @name_param        = :display_name unless v2?
      @name_param        = :name if v2?

      @description_param = :display_description unless v2?
      @description_param = :description if v2?
    end

    def v2?
      @service.kind_of? Fog::OpenStack::Volume::V2::Real
    end

    def setup_test_object(options)
      type = options.delete(:type)
      case type
      when :volume
        puts "Checking for leftovers..." if ENV['DEBUG_VERBOSE']
        volume_name = options[@name_param]
        # if this fails, cleanup this object (it was left over from a failed test run)
        @service.volumes.all(@name_param => volume_name).length.must_equal 0

        puts "Creating volume #{volume_name}..." if ENV['DEBUG_VERBOSE']
        return @service.volumes.create(options)

      when :transfer
        puts "Checking for leftovers..." if ENV['DEBUG_VERBOSE']
        transfer_name = options[:name]
        # if this fails, cleanup this object (it was left over from a failed test run)
        @service.transfers.all(:name => transfer_name).length.must_equal 0

        puts "Creating transfer #{transfer_name}..." if ENV['DEBUG_VERBOSE']
        return @service.transfers.create(options)

      when :snapshot
        puts "Checking for leftovers..." if ENV['DEBUG_VERBOSE']
        snapshot_name = options[@name_param]
        # if this fails, cleanup this object (it was left over from a failed test run)
        @service.snapshots.all(@name_param => snapshot_name).length.must_equal 0

        puts "Creating snapshot #{snapshot_name}..." if ENV['DEBUG_VERBOSE']
        return @service.snapshots.create(options)

      else
        raise ArgumentError, "don't know how to setup a test object of type #{type.inspect}"
      end
    end

    def cleanup_test_object(collection, id)
      # wait for the object to be deletable
      Fog.wait_for do
        begin
          object = collection.get(id)
          puts "Current status: #{object ? object.status : 'deleted'}" if ENV['DEBUG_VERBOSE']
          object.nil? || (%w[available error].include? object.status.downcase)
        end
      end

      object = collection.get(id)

      if object && object.status.casecmp('awaiting-transfer').zero?
        object.reset_status 'available'
      end

      puts "Deleting object #{object.class} #{id}..." if ENV['DEBUG_VERBOSE']
      object.destroy if object

      # wait for the object to be deleted
      Fog.wait_for do
        begin
          object = collection.get(id)
          puts "Current status: #{object ? object.status : 'deleted'}" if ENV['DEBUG_VERBOSE']
          object.nil?
        end
      end
    end

    it 'CRUD volumes' do
      VCR.use_cassette('volume_crud') do
        begin
          volume_name            = "fog-testvolume-1"
          volume_description     = 'This is the volume description.'
          volume_new_description = 'This is the updated volume description.'
          volume_new_name        = "fog-updated-testvolume-1"
          volume_size            = 1 # in GB

          # create volume
          volume_id              = setup_test_object(:type              => :volume,
                                                     @name_param        => volume_name,
                                                     @description_param => volume_description,
                                                     :size              => volume_size).id

          @service.volumes.all(@name_param => volume_name).length.must_equal 1

          # check retrieval of volume by ID
          puts "Retrieving volume by ID..." if ENV['DEBUG_VERBOSE']

          volume = @service.volumes.get(volume_id)
          volume.must_be_kind_of Fog::OpenStack::Volume::Volume

          volume.id.must_equal volume_id
          volume.display_name.must_equal volume_name unless v2?
          volume.name.must_equal volume_name if v2?
          volume.display_description.must_equal volume_description unless v2?
          volume.description.must_equal volume_description if v2?
          volume.size.must_equal volume_size

          puts "Waiting for volume to be available..." if ENV['DEBUG_VERBOSE']
          volume.wait_for { ready? }

          # check retrieval of volume by name
          puts "Retrieving volume by name..." if ENV['DEBUG_VERBOSE']

          volumes = @service.volumes.all(@name_param => volume_name)
          volumes.length.must_equal 1
          volume = volumes[0]
          volume.must_be_kind_of Fog::OpenStack::Volume::Volume

          volume.id.must_equal volume_id
          volume.display_name.must_equal volume_name unless v2?
          volume.name.must_equal volume_name if v2?
          volume.display_description.must_equal volume_description unless v2?
          volume.description.must_equal volume_description if v2?
          volume.size.must_equal volume_size

          # Update the volume's name
          volume.update(@name_param => volume_new_name)

          volumes = @service.volumes.all(@name_param => volume_new_name)
          volume  = volumes.first
          volume.must_be_kind_of Fog::OpenStack::Volume::Volume
          volume.display_name.must_equal volume_new_name unless v2?
          volume.name.must_equal volume_new_name if v2?

          # Check that save does an update
          volume.description         = volume_new_description if v2?
          volume.display_description = volume_new_description unless v2?
          volume.save

          volume = @service.volumes.get(volume_id)
          volume.display_description.must_equal volume_new_description unless v2?
          volume.description.must_equal volume_new_description if v2?
        ensure
          # delete volume
          cleanup_test_object(@service.volumes, volume_id)
        end
      end
    end

    it 'reads volume types' do
      VCR.use_cassette('volume_type_read') do
        # list all volume types
        puts "Listing volume types..." if ENV['DEBUG_VERBOSE']

        types = @service.volume_types.all
        types.length.must_be :>, 0
        types.each do |type|
          type.name.must_be_kind_of String
        end

        type_id   = types[0].id
        type_name = types[0].name

        # get a single volume type by ID
        puts "Retrieving volume type by ID..." if ENV['DEBUG_VERBOSE']

        type = @service.volume_types.get(type_id)
        type.must_be_kind_of Fog::OpenStack::Volume::VolumeType
        type.id.must_equal type_id
        type.name.must_equal type_name

        # get a single volume type by name
        puts "Retrieving volume type by name..." if ENV['DEBUG_VERBOSE']

        type = @service.volume_types.all(type_name).first
        type.must_be_kind_of Fog::OpenStack::Volume::VolumeType
        type.id.must_equal type_id
        type.name.must_equal type_name
      end
    end

    it 'can extend volumes' do
      VCR.use_cassette('volume_extend') do
        begin
          volume_size_small = 1 # in GB
          volume_size_large = 2 # in GB

          volume = setup_test_object(:type       => :volume,
                                     @name_param => 'fog-testvolume-1',
                                     :size       => volume_size_small)
          volume.wait_for { ready? && size == volume_size_small }

          # extend volume
          puts "Extending volume..." if ENV['DEBUG_VERBOSE']
          volume.extend(volume_size_large)
          volume.wait_for do
            status == 'error_extending' || (ready? && size == volume_size_large)
          end
          volume.status.wont_equal 'error_extending'

          # shrinking is not allowed in OpenStack
          puts "Shrinking volume should fail..." if ENV['DEBUG_VERBOSE']
          proc do
            volume.extend(volume_size_small)
          end.must_raise(Excon::Errors::BadRequest,
                         /Invalid input received: New size for extend must be greater than current size./)
        ensure
          # delete volume
          cleanup_test_object(@service.volumes, volume.nil? ? nil : volume.id)

          # check that extending a non-existing volume fails
          puts "Extending deleted volume should fail..." if ENV['DEBUG_VERBOSE']
          proc { @service.extend_volume(volume.id, volume_size_small) }.must_raise Fog::OpenStack::Volume::NotFound
        end
      end
    end

    it 'can create and accept volume transfers' do
      VCR.use_cassette('volume_transfer_and_accept') do
        begin
          transfer_name = 'fog-testtransfer-1'

          # create volume object
          volume        = setup_test_object(:type       => :volume,
                                            @name_param => 'fog-testvolume-1',
                                            :size       => 1)
          volume.wait_for { ready? }

          # create transfer object
          transfer = setup_test_object(:type      => :transfer,
                                       :name      => transfer_name,
                                       :volume_id => volume.id)
          # we need to save the auth_key NOW, it's only present in the response
          # from the create_transfer request
          auth_key    = transfer.auth_key
          transfer_id = transfer.id

          # check retrieval of transfer by ID
          puts 'Retrieving transfer by ID...' if ENV['DEBUG_VERBOSE']

          transfer = @service.transfers.get(transfer_id)
          transfer.must_be_kind_of Fog::OpenStack::Volume::Transfer

          transfer.id.must_equal transfer_id
          transfer.name.must_equal transfer_name
          transfer.volume_id.must_equal volume.id

          # check retrieval of transfer by name
          puts 'Retrieving transfer by name...' if ENV['DEBUG_VERBOSE']

          transfers = @service.transfers.all(:name => transfer_name)
          transfers.length.must_equal 1
          transfer = transfers[0]
          transfer.must_be_kind_of Fog::OpenStack::Volume::Transfer

          transfer.id.must_equal transfer_id
          transfer.name.must_equal transfer_name
          transfer.volume_id.must_equal volume.id
          # to accept the transfer, we need a second connection to a different project
          puts 'Checking object visibility from different projects...' if ENV['DEBUG_VERBOSE']
          other_service = service_class.new(
            :openstack_auth_url     => @os_auth_url,
            :openstack_region       => ENV['OS_REGION_NAME'] || 'RegionOne',
            :openstack_api_key      => ENV['OS_PASSWORD_OTHER'] || 'password',
            :openstack_username     => ENV['OS_USERNAME_OTHER'] || 'demo',
            :openstack_domain_name  => ENV['OS_USER_DOMAIN_NAME'] || 'Default',
            :openstack_project_name => ENV['OS_PROJECT_NAME_OTHER'] || 'demo'
          )

          # check that recipient cannot see the transfer object
          assert_nil other_service.transfers.get(transfer.id)
          other_service.transfers.all(:name => transfer_name).length.must_equal 0

          # # check that recipient cannot see the volume before transfer
          # proc { other_service.volumes.get(volume.id) }.must_raise Fog::OpenStack::Compute::NotFound
          # other_service.volumes.all(@name_param => volume_name).length.must_equal 0

          # The recipient can inexplicably see the volume even before the
          # transfer, so to confirm that the transfer happens, we record its tenant ID.
          volume.tenant_id.must_match(/^[0-9a-f-]+$/) # should look like a UUID
          source_tenant_id = volume.tenant_id

          # check that accept_transfer fails without valid transfer ID and auth key
          bogus_uuid = 'ec8ff7e8-81e2-4e12-b9fb-3e8890612c2d' # from Fog::UUID.uuid, but fixed to play nice with VCR
          proc { other_service.transfers.accept(bogus_uuid, auth_key) }.must_raise Fog::OpenStack::Volume::NotFound
          proc { other_service.transfers.accept(transfer_id, 'invalidauthkey') }.must_raise Excon::Errors::BadRequest

          # accept transfer
          puts 'Accepting transfer...' if ENV['DEBUG_VERBOSE']
          transfer = other_service.transfers.accept(transfer.id, auth_key)
          transfer.must_be_kind_of Fog::OpenStack::Volume::Transfer

          transfer.id.must_equal transfer_id
          transfer.name.must_equal transfer_name

          # check that recipient can see the volume
          volume = other_service.volumes.get(volume.id)
          volume.must_be_kind_of Fog::OpenStack::Volume::Volume

          # # check that sender cannot see the volume anymore
          # proc { @service.volumes.get(volume.id) }.must_raise Fog::OpenStack::Compute::NotFound
          # @service.volumes.all(@name_param => volume_name).length.must_equal 0

          # As noted above, both users seem to be able to see the volume at all times.
          # Check change of ownership by looking at the tenant_id, instead.
          volume.tenant_id.must_match(/^[0-9a-f-]+$/) # should look like a UUID
          volume.tenant_id.wont_equal(source_tenant_id)

          # check that the transfer object is gone on both sides
          [@service, other_service].each do |service|
            assert_nil service.transfers.get(transfer.id)
            service.transfers.all(:name => transfer_name).length.must_equal 0
          end
        ensure
          # cleanup volume
          cleanup_test_object(other_service.volumes, volume.nil? ? nil : volume.id) if other_service
          cleanup_test_object(@service.volumes, volume.nil? ? nil : volume.id) unless other_service
        end
      end
    end

    it 'can create and delete volume transfers (v2 only)' do
      if v2?
        VCR.use_cassette('volume_transfer_and_delete') do
          begin
            # create volume object
            volume = setup_test_object(:type       => :volume,
                                       @name_param => 'fog-testvolume-1',
                                       :size       => 1)
            volume.wait_for { ready? }

            # create transfer object
            transfer = setup_test_object(:type      => :transfer,
                                         :name      => 'fog-testtransfer-1',
                                         :volume_id => volume.id)
            # we need to save the auth_key NOW, it's only present in the response
            # from the create_transfer request
            auth_key      = transfer.auth_key
            transfer_id   = transfer.id

            # to try to accept the transfer, we need a second connection to a different project
            other_service = service_class.new(
              :openstack_auth_url     => @os_auth_url,
              :openstack_region       => ENV['OS_REGION_NAME'] || 'RegionOne',
              :openstack_api_key      => ENV['OS_PASSWORD_OTHER'] || 'password',
              :openstack_username     => ENV['OS_USERNAME_OTHER'] || 'demo',
              :openstack_domain_name  => ENV['OS_USER_DOMAIN_NAME'] || 'Default',
              :openstack_project_name => ENV['OS_PROJECT_NAME_OTHER'] || 'demo'
            )

            # delete transfer again
            transfer.destroy

            # check that transfer cannot be accepted when it has been deleted
            puts 'Checking that accepting a deleted transfer fails...' if ENV['DEBUG_VERBOSE']
            proc { other_service.transfers.accept(transfer_id, auth_key) }.must_raise Fog::OpenStack::Volume::NotFound
          ensure
            # cleanup volume
            cleanup_test_object(@service.volumes, volume.id) if volume
          end
        end
      end
    end

    it 'can create, update and delete volume snapshots' do
      VCR.use_cassette('volume_snapshot_and_delete') do
        begin
          # create volume object
          volume = setup_test_object(:type       => :volume,
                                     @name_param => 'fog-testvolume-1',
                                     :size       => 1)
          volume.wait_for { ready? }

          # create snapshot object
          snapshot = setup_test_object(:type              => :snapshot,
                                       @name_param        => 'fog-testsnapshot-1',
                                       @description_param => 'Test snapshot',
                                       :volume_id         => volume.id)
          snapshot_id = snapshot.id

          # wait for the snapshot to be available
          Fog.wait_for do
            begin
              object = @service.snapshots.get(snapshot.id)
              object.wont_be_nil
              puts "Current status: #{object ? object.status : 'deleted'}" if ENV['DEBUG_VERBOSE']
              object.nil? || (%w[available error].include? object.status.downcase)
            end
          end

          # Update snapshot
          snapshot.update(@description_param => 'Updated description')

          updated_snapshot = @service.snapshots.get(snapshot.id)
          updated_snapshot.description.must_equal 'Updated description' if v2?
          updated_snapshot.display_description.must_equal 'Updated description' unless v2?

          # delete snapshot
          snapshot.destroy
          # wait for the snapshot to be deleted
          Fog.wait_for do
            begin
              object = @service.snapshots.get(snapshot_id)
              puts "Current status: #{object ? object.status : 'deleted'}" if ENV['DEBUG_VERBOSE']
              object.nil?
            end
          end
        ensure
          # cleanup volume
          begin
            snapshot.destroy if snapshot
          rescue Fog::OpenStack::Volume::NotFound
            # Don't care if it doesn't exist
          end

          cleanup_test_object(@service.volumes, volume.id) if volume
        end
      end
    end

    it 'can create, update and delete volume metadata' do
      VCR.use_cassette('volume_metadata_crud') do
        begin
          # create volume object with metadata
          volume = setup_test_object(:type       => :volume,
                                     @name_param => 'fog-testvolume-1',
                                     :size       => 1,
                                     :metadata   => {'some_metadata' => 'this is meta',
                                                     'more_metadata' => 'even more meta'})
          volume.wait_for { ready? }

          updated_volume = @service.volumes.get(volume.id)
          check_metadata = updated_volume.metadata
          check_metadata.size.must_equal 2
          check_metadata['some_metadata'].must_equal 'this is meta'
          check_metadata['more_metadata'].must_equal 'even more meta'

          # update metadata
          volume.update_metadata('some_metadata' => 'this is updated',
                                 'new_metadata'  => 'this is new')

          updated_volume = @service.volumes.get(volume.id)
          check_metadata = updated_volume.metadata
          check_metadata.size.must_equal 3
          check_metadata['some_metadata'].must_equal 'this is updated'
          check_metadata['more_metadata'].must_equal 'even more meta'
          check_metadata['new_metadata'].must_equal 'this is new'

          # replace metadata
          volume.replace_metadata('some_metadata'  => 'this is updated again',
                                  'newer_metadata' => 'this is newer')

          updated_volume = @service.volumes.get(volume.id)
          check_metadata = updated_volume.metadata
          check_metadata.size.must_equal 2
          check_metadata['some_metadata'].must_equal 'this is updated again'
          check_metadata['newer_metadata'].must_equal 'this is newer'

          # delete metadata
          volume.delete_metadata('some_metadata')

          updated_volume = @service.volumes.get(volume.id)
          check_metadata = updated_volume.metadata
          check_metadata.size.must_equal 1
          check_metadata['newer_metadata'].must_equal 'this is newer'
        ensure
          # cleanup volume
          cleanup_test_object(@service.volumes, volume.id) if volume
        end
      end
    end

    it 'can create, update and delete volume snapshot metadata' do
      VCR.use_cassette('volume_snapshot_metadata_crud') do
        begin
          # create volume object with metadata
          volume = setup_test_object(:type       => :volume,
                                     @name_param => 'fog-testvolume-1',
                                     :size       => 1,
                                     :metadata   => {'some_metadata' => 'this is meta',
                                                     'more_metadata' => 'even more meta'})
          volume.wait_for { ready? }

          # create snapshot object
          snapshot = setup_test_object(:type              => :snapshot,
                                       @name_param        => 'fog-testsnapshot-1',
                                       @description_param => 'Test snapshot',
                                       :volume_id         => volume.id)
          snapshot_id = snapshot.id

          # wait for the snapshot to be available
          Fog.wait_for do
            begin
              object = @service.snapshots.get(snapshot_id)
              object.wont_be_nil
              puts "Current status: #{object ? object.status : 'deleted'}" if ENV['DEBUG_VERBOSE']
              object.nil? || (%w[available error].include? object.status.downcase)
            end
          end

          updated_snapshot = @service.snapshots.get(snapshot_id)
          check_metadata   = updated_snapshot.metadata
          check_metadata.size.must_equal 0

          # update metadata
          snapshot.update_metadata('some_snapshot_metadata' => 'this is data',
                                   'new_snapshot_metadata'  => 'this is new')

          updated_snapshot = @service.snapshots.get(snapshot_id)
          check_metadata   = updated_snapshot.metadata
          check_metadata.size.must_equal 2
          check_metadata['some_snapshot_metadata'].must_equal 'this is data'
          check_metadata['new_snapshot_metadata'].must_equal 'this is new'

          # delete metadata
          snapshot.delete_metadata('some_snapshot_metadata')

          updated_snapshot = @service.snapshots.get(snapshot_id)
          check_metadata   = updated_snapshot.metadata
          check_metadata.size.must_equal 1
          check_metadata['new_snapshot_metadata'].must_equal 'this is new'
        ensure
          # cleanup volume
          cleanup_test_object(@service.snapshots, snapshot.id) if snapshot
          cleanup_test_object(@service.volumes, volume.id) if volume
        end
      end
    end

    # TODO: tests for snapshots
    it 'responds to list_snapshots_detailed' do
      @service.respond_to?(:list_snapshots_detailed).must_equal true
    end

    # TODO: tests for quotas
  end
end
