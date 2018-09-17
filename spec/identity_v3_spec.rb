require 'spec_helper'
require_relative './shared_context'

describe Fog::OpenStack::Identity::V3 do
  before :all do
    @openstack_vcr = OpenStackVCR.new(
      :vcr_directory => 'spec/fixtures/openstack/identity_v3',
      :service_class => Fog::OpenStack::Identity::V3
    )
    @service = @openstack_vcr.service
    @os_auth_url = @openstack_vcr.os_auth_url
  end

  it 'authenticates with password, userid and domain_id' do
    VCR.use_cassette('authv3_a') do
      Fog::OpenStack::Identity::V3.new(
        :openstack_domain_id => @openstack_vcr.domain_id,
        :openstack_api_key   => @openstack_vcr.password,
        :openstack_userid    => @openstack_vcr.user_id,
        :openstack_region    => @openstack_vcr.region,
        :openstack_auth_url  => @os_auth_url
      )
    end
  end

  it 'authenticates with password, username and domain_id' do
    VCR.use_cassette('authv3_b') do
      Fog::OpenStack::Identity::V3.new(
        :openstack_domain_id => @openstack_vcr.domain_id,
        :openstack_api_key   => @openstack_vcr.password,
        :openstack_username  => @openstack_vcr.username,
        :openstack_region    => @openstack_vcr.region,
        :openstack_auth_url  => @os_auth_url
      )
    end
  end

  it 'authenticates with password, username and domain_name' do
    VCR.use_cassette('authv3_c') do
      Fog::OpenStack::Identity::V3.new(
        :openstack_user_domain => @openstack_vcr.domain_name,
        :openstack_api_key     => @openstack_vcr.password,
        :openstack_username    => @openstack_vcr.username,
        :openstack_region      => @openstack_vcr.region,
        :openstack_auth_url    => @os_auth_url
      )
    end
  end

  it 'authenticates in another region' do
    VCR.use_cassette('idv3_endpoint') do
      @endpoints_all = @service.endpoints.all
    end
    endpoints_in_region = @endpoints_all.select { |endpoint| endpoint.region == @openstack_vcr.region_other }

    unless endpoints_in_region.empty?
      VCR.use_cassette('idv3_other_region') do
        @fog = Fog::OpenStack::Identity::V3.new(
          :openstack_region   => @openstack_vcr.region_other,
          :openstack_auth_url => @os_auth_url,
          :openstack_userid   => @openstack_vcr.user_id,
          :openstack_api_key  => @openstack_vcr.password
        )
        @fog.wont_equal nil
      end
    end
  end

  it 'get an unscoped token, then reauthenticate with it' do
    VCR.use_cassette('authv3_unscoped_reauth') do
      id_v3 = Fog::OpenStack::Identity::V3.new(
        :openstack_api_key  => @openstack_vcr.password,
        :openstack_userid   => @openstack_vcr.user_id,
        :openstack_region   => @openstack_vcr.region,
        :openstack_auth_url => @os_auth_url
      )

      auth_params = {
        :provider             => "openstack",
        :openstack_auth_token => id_v3.credentials[:openstack_auth_token],
        :openstack_auth_url   => @os_auth_url,
        :openstack_region     => @openstack_vcr.region
      }
      @fog2 = Fog::OpenStack::Identity::V3.new(auth_params)

      @fog2.wont_equal nil
      token = @fog2.credentials[:openstack_auth_token]
      token.wont_equal nil
    end
  end

  it 'authenticates with project scope' do
    VCR.use_cassette('authv3_project') do
      Fog::OpenStack::Identity::V3.new(
        :openstack_project_name => @openstack_vcr.project_name,
        :openstack_domain_name  => @openstack_vcr.domain_name,
        :openstack_api_key      => @openstack_vcr.password,
        :openstack_username     => @openstack_vcr.username,
        :openstack_region       => @openstack_vcr.region,
        :openstack_auth_url     => @os_auth_url
      )
    end
  end

  it 'get an unscoped token, then use it to get a scoped token' do
    VCR.use_cassette('authv3_unscoped') do
      id_v3 = Fog::OpenStack::Identity::V3.new(
        :openstack_api_key  => @openstack_vcr.password,
        :openstack_userid   => @openstack_vcr.user_id,
        :openstack_region   => @openstack_vcr.region,
        :openstack_auth_url => @os_auth_url
      )

      # Exchange it for a project-scoped token
      auth = Fog::OpenStack::Identity::V3.new(
        :openstack_project_name => @openstack_vcr.project_name,
        :openstack_domain_name  => @openstack_vcr.domain_name,
        :openstack_auth_token   => id_v3.credentials[:openstack_auth_token],
        :openstack_region       => @openstack_vcr.region,
        :openstack_auth_url     => @os_auth_url
      )

      token = auth.credentials[:openstack_auth_token]

      # We can use the unscoped token to validate the scoped token
      validated_token = id_v3.tokens.validate(token)
      validated_token.wont_equal nil

      id_v3.tokens.check(token)
      proc { id_v3.tokens.check('random-token') }.must_raise Fog::OpenStack::Identity::NotFound
    end
  end

  it "find specific user, lists users" do
    VCR.use_cassette('idv3_users') do
      proc { @service.users.find_by_id 'u-random-blah' }.must_raise Fog::OpenStack::Identity::NotFound

      admin_user = @service.users.find_by_name @openstack_vcr.username
      admin_user.length.must_equal 1

      users = @service.users
      users.wont_equal nil
      users.length.wont_equal 0

      users_all = @service.users.all
      users_all.wont_equal nil
      users_all.length.wont_equal 0

      admin_by_id = @service.users.find_by_id admin_user.first.id
      admin_by_id.wont_equal nil

      @service.users.find_by_name('pimpernel').length.must_equal 0
    end
  end

  it 'CRUD users' do
    VCR.use_cassette('idv3_user_crud') do
      # Make sure there are no existing users called foobar or baz
      %w[foobar baz].each do |username|
        user = @service.users.find_by_name(username).first
        if user
          user.update(:enabled => false)
          user.destroy
        end
      end
      @service.users.find_by_name('foobar').length.must_equal 0
      @service.users.find_by_name('baz').length.must_equal 0

      # Create a user called foobar
      foobar_user = @service.users.create(:name     => 'foobar',
                                          :email    => 'foobar@example.com',
                                          :password => 's3cret!')
      foobar_id = foobar_user.id
      @service.users.find_by_name('foobar').length.must_equal 1

      # Rename it to baz and disable it (required so we can delete it)
      foobar_user.update(:name => 'baz', :enabled => false)
      foobar_user.name.must_equal 'baz'

      # Read the user freshly and check the name & enabled state
      @service.users.find_by_name('baz').length.must_equal 1
      baz_user = @service.users.find_by_id foobar_id
      baz_user.wont_equal nil
      baz_user.name.must_equal 'baz'
      baz_user.email.must_equal 'foobar@example.com'
      baz_user.enabled.must_equal false

      # Try to create the user again
      proc do
        @service.users.create(:name     => 'baz',
                              :email    => 'foobar@example.com',
                              :password => 's3cret!')
      end.must_raise Excon::Errors::Conflict

      # Delete the user
      baz_user.destroy
      # Check that the deletion worked
      proc { @service.users.find_by_id foobar_id }.must_raise Fog::OpenStack::Identity::NotFound
      @service.users.all.select { |user| %w[foobar baz].include? user.name }.length.must_equal 0
      @service.users.find_by_name('foobar').length.must_equal 0
      @service.users.find_by_name('baz').length.must_equal 0
    end
  end

  it "CRUD & manipulate groups" do
    VCR.use_cassette('idv3_group_crud_mutation') do
      # Make sure there are no existing groups called foobar or baz
      @service.groups.all.select { |group| %w[foobar baz].include? group.name }.each(&:destroy)
      @service.groups.all.select { |group| %w[foobar baz].include? group.name }.length.must_equal 0

      # Create a group called foobar
      foobar_group = @service.groups.create(:name => 'foobar', :description => "Group of Foobar users")
      foobar_id = foobar_group.id
      @service.groups.all.select { |group| group.name == 'foobar' }.length.must_equal 1

      # Rename it to baz
      foobar_group.update(:name => 'baz', :description => "Group of Baz users")
      foobar_group.name.must_equal 'baz'

      # Read the group freshly and check the name
      @service.groups.all.select { |group| group.name == 'baz' }.length.must_equal 1
      baz_group = @service.groups.find_by_id foobar_id
      baz_group.wont_equal nil
      baz_group.name.must_equal 'baz'

      # Add users to the group
      foobar_user1 = @service.users.create(:name     => 'foobar1',
                                           :email    => 'foobar1@example.com',
                                           :password => 's3cret!1')
      foobar_user2 = @service.users.create(:name     => 'foobar2',
                                           :email    => 'foobar2@example.com',
                                           :password => 's3cret!2')

      foobar_user1.groups.length.must_equal 0
      baz_group.users.length.must_equal 0

      baz_group.add_user(foobar_user1.id)

      # Check that a user is in the group
      foobar_user1.groups.length.must_equal 1
      (baz_group.contains_user? foobar_user1.id).must_equal true

      baz_group.add_user(foobar_user2.id)

      # List users in the group
      baz_group.users.length.must_equal 2

      # Remove a user from the group
      baz_group.remove_user(foobar_user1.id)
      (baz_group.contains_user? foobar_user1.id).must_equal false
      baz_group.users.length.must_equal 1

      # Delete the users and make sure they are no longer in the group
      foobar_user1.destroy
      foobar_user2.destroy
      (baz_group.contains_user? foobar_user2.id).must_equal false
      baz_group.users.length.must_equal 0

      # Delete the group
      baz_group.destroy
      proc { @service.groups.find_by_id foobar_id }.must_raise Fog::OpenStack::Identity::NotFound
      @service.groups.all.select { |group| %w[foobar baz].include? group.name }.length.must_equal 0
    end
  end

  it "gets a token, checks it and then revokes it" do
    VCR.use_cassette('idv3_token') do
      auth = {
        :auth => {
          :identity => {
            :methods  => %w[password],
            :password => {
              :user => {
                :id       => @openstack_vcr.user_id,
                :password => @openstack_vcr.password
              }
            }
          },
          :scope    => {
            :project => {
              :domain => {
                :name => @openstack_vcr.domain_name
              },
              :name   => @openstack_vcr.project_name
            }
          }
        }
      }

      token = @service.tokens.authenticate(auth)
      token.wont_equal nil

      validated_token = @service.tokens.validate token.value
      validated_token.wont_equal nil

      @service.tokens.check(token.value)
      @service.tokens.revoke(token.value)

      proc { @service.tokens.check(token.value) }.must_raise Fog::OpenStack::Identity::NotFound
    end
  end

  it 'authenticates with a token' do
    VCR.use_cassette('authv3_token') do
      # Setup - get a non-admin token to check by using username/password authentication to start with
      auth_url = @os_auth_url

      begin
        foobar_user = @service.users.create(
          :name      => 'foobar_385',
          :email     => 'foobar_demo@example.com',
          :domain_id => @openstack_vcr.domain_id,
          :password  => 's3cret!'
        )

        foobar_role = @service.roles.create(:name => 'foobar_role390')
        foobar_user.grant_role(foobar_role.id)

        nonadmin_v3 = Fog::OpenStack::Identity::V3.new(
          :openstack_domain_id => foobar_user.domain_id,
          :openstack_api_key   => 's3cret!',
          :openstack_username  => 'foobar_385',
          :openstack_region    => @openstack_vcr.region,
          :openstack_auth_url  => auth_url
        )

        # Test - check the token validity by using it to create a new Fog::OpenStack::Identity::V3 instance
        token_check = Fog::OpenStack::Identity::V3.new(
          :openstack_auth_token => nonadmin_v3.auth_token,
          :openstack_region     => @openstack_vcr.region,
          :openstack_auth_url   => auth_url
        )

        token_check.wont_equal nil

        proc do
          Fog::OpenStack::Identity::V3.new(
            :openstack_auth_token => 'blahblahblah',
            :openstack_region     => @openstack_vcr.region,
            :openstack_auth_url   => auth_url
          )
        end.must_raise Excon::Errors::NotFound
      ensure
        # Clean up
        foobar_user ||= @service.users.find_by_name('foobar_385').first
        foobar_user.destroy if foobar_user
        foobar_role ||= @service.roles.all.select { |role| role.name == 'foobar_role390' }.first
        foobar_role.destroy if foobar_role
      end
    end
  end

  it "lists domains" do
    VCR.use_cassette('idv3_domain') do
      domains = @service.domains
      domains.wont_equal nil
      domains.length.wont_equal 0

      domains_all = @service.domains.all
      domains_all.wont_equal nil
      domains_all.length.wont_equal 0

      default_domain = @service.domains.find_by_id @openstack_vcr.domain_id
      default_domain.wont_equal nil

      proc { @service.domains.find_by_id 'atlantis' }.must_raise Fog::OpenStack::Identity::NotFound
    end
  end

  it "CRUD domains" do
    VCR.use_cassette('idv3_domain_crud') do
      begin
        # Create a domain called foobar
        foobar_domain = @service.domains.create(:name => 'foobar')
        foobar_id = foobar_domain.id
        @service.domains.all(:name => 'foobar').length.must_equal 1

        # Rename it to baz and disable it (required so we can delete it)
        foobar_domain.update(:name => 'baz', :enabled => false)
        foobar_domain.name.must_equal 'baz'

        # Read the domain freshly and check the name & enabled state
        @service.domains.all(:name => 'baz').length.must_equal 1
        baz_domain = @service.domains.find_by_id foobar_id
        baz_domain.wont_equal nil
        baz_domain.name.must_equal 'baz'
        baz_domain.enabled.must_equal false
      ensure
        # Delete the domains
        begin
          if baz_domain
            baz_domain.update(:enabled => false)
            baz_domain.destroy
          end
          if foobar_domain
            foobar_domain.update(:enabled => false)
            foobar_domain.destroy
          end
        rescue
        end
        # Check that the deletion worked
        proc { @service.domains.find_by_id foobar_id }.must_raise Fog::OpenStack::Identity::NotFound if foobar_id
        %w[foobar baz].each do |domain_name|
          @service.domains.all(:name => domain_name).length.must_equal 0
        end
      end
    end
  end

  it "Manipulates roles on domains" do
    # Note that the domain is implicit in the user operations here

    VCR.use_cassette('idv3_domain_roles_mutation') do
      begin
        foobar_user = @service.users.create(:name     => 'foobar_role_user',
                                            :email    => 'foobar@example.com',
                                            :password => 's3cret!')

        # User has no roles initially
        foobar_user.roles.length.must_equal 0

        # Create a role and add it to the user in the user's domain
        foobar_role = @service.roles.create(:name => 'foobar_role')
        foobar_user.grant_role(foobar_role.id)
        foobar_user.roles.length.must_equal 1
        assignments = @service.role_assignments.all(:user_id => foobar_user.id)
        assignments.length.must_equal 1
        assignments.first.role['id'].must_equal foobar_role.id
        assignments.first.user['id'].must_equal foobar_user.id
        assignments.first.scope['domain']['id'].must_equal foobar_user.domain_id
        assignments.first.links['assignment'].must_match %r{/v3/domains/#{foobar_user.domain_id}/users/#{foobar_user.id}/roles/#{foobar_role.id}}

        # Quick test of @service.role_assignments.all while we're at it
        all_assignments = @service.role_assignments.all
        all_assignments.length.must_be :>, 0

        # Check that the user has the role
        foobar_user.check_role(foobar_role.id).must_equal true

        # Revoke the role from the user
        foobar_user.revoke_role(foobar_role.id)
        foobar_user.check_role(foobar_role.id).must_equal false
      ensure
        foobar_user ||= @service.users.find_by_name('foobar_role_user').first
        foobar_user.destroy if foobar_user
        foobar_role ||= @service.roles.all.select { |role| role.name == 'foobar_role' }.first
        foobar_role.destroy if foobar_role
      end
    end
  end

  it "Manipulates roles on domain groups" do
    VCR.use_cassette('idv3_domain_group_roles_mutation') do
      skip "Manipulates roles on domain groups to be fixed"
      begin
        # Create a domain called foobar
        foobar_domain = @service.domains.create(:name => 'd-foobar')

        # Create a group in this domain
        foobar_group = @service.groups.create(:name        => 'g-foobar',
                                              :description => "Group of Foobar users",
                                              :domain_id   => foobar_domain.id)

        # Create a user in the domain
        foobar_user = @service.users.create(:name      => 'u-foobar_foobar',
                                            :email     => 'foobar@example.com',
                                            :password  => 's3cret!',
                                            :domain_id => foobar_domain.id)

        # User has no roles initially
        foobar_user.roles.length.must_equal 0
        # Create a role and add it to the domain group
        foobar_role = @service.roles.all.select { |role| role.name == 'foobar_role' }.first
        foobar_role.destroy if foobar_role
        foobar_role = @service.roles.create(:name => 'foobar_role')

        foobar_group.grant_role foobar_role.id
        foobar_group.roles.length.must_equal 1

        # Add user to the group and check that it inherits the role
        foobar_user.check_role foobar_role.id.wont_equal nil
        @service.role_assignments.all(:user_id => foobar_user.id, :effective => true).length.must_equal 0
        foobar_group.add_user foobar_user.id
        foobar_user.check_role(foobar_role.id).must_equal false # Still false in absolute assignment terms
        assignments = @service.role_assignments.all(:user_id => foobar_user.id, :effective => true)

        assignments.length.must_equal 1
        assignments.first.role['id'].must_equal foobar_role.id
        assignments.first.user['id'].must_equal foobar_user.id
        assignments.first.scope['domain']['id'].must_equal foobar_user.domain_id
        assignments.first.links['assignment'].must_match %r{/v3/domains/#{foobar_domain.id}/groups/#{foobar_group.id}/roles/#{foobar_role.id}}
        assignments.first.links['membership'].must_match %r{/v3/groups/#{foobar_group.id}/users/#{foobar_user.id}}

        group_assignments = @service.role_assignments.all(:group_id => foobar_group.id)
        group_assignments.length.must_equal 1
        group_assignments.first.role['id'].must_equal foobar_role.id
        group_assignments.first.group['id'].must_equal foobar_group.id
        group_assignments.first.scope['domain']['id'].must_equal foobar_user.domain_id
        group_assignments.first.links['assignment'].must_match %r{/v3/domains/#{foobar_domain.id}/groups/#{foobar_group.id}/roles/#{foobar_role.id}}

        # Revoke the role from the group and check the user no longer has it
        foobar_group.revoke_role foobar_role.id
        @service.role_assignments.all(:user_id => foobar_user.id, :effective => true).length.must_equal 0
      ensure
        # Clean up
        foobar_user ||= @service.users.find_by_name('u-foobar_foobar').first
        foobar_user.destroy if foobar_user
        foobar_group ||= @service.groups.all.select { |group| group.name == 'g-foobar' }.first
        foobar_group.destroy if foobar_group
        foobar_role ||= @service.roles.all.select { |role| role.name == 'foobar_role' }.first
        foobar_role.destroyif foobar_role
        foobar_domain ||= @service.domains.all.select { |domain| domain.name == 'd-foobar' }.first
        if foobar_domain
          foobar_domain.update(:enabled => false)
          foobar_domain.destroy
        end
      end
    end
  end

  it "lists roles" do
    VCR.use_cassette('idv3_role') do
      roles = @service.roles
      roles.wont_equal nil
      roles.length.wont_equal 0

      roles_all = @service.roles.all
      roles_all.wont_equal nil
      roles_all.length.wont_equal 0

      role_by_id = @service.roles.find_by_id roles_all.first.id
      role_by_id.wont_equal nil

      proc { @service.roles.find_by_id 'atlantis' }.must_raise Fog::OpenStack::Identity::NotFound
    end
  end

  it "CRUD roles" do
    VCR.use_cassette('idv3_role_crud') do
      begin
        # Create a role called foobar
        foobar_role = @service.roles.create(:name => 'foobar23')
        foobar_id = foobar_role.id
        @service.roles.all(:name => 'foobar23').length.must_equal 1

        # Rename it to baz
        foobar_role.update(:name => 'baz23')
        foobar_role.name.must_equal 'baz23'

        # Read the role freshly and check the name & enabled state
        @service.roles.all(:name => 'baz23').length.must_equal 1
        baz_role = @service.roles.find_by_id foobar_id
        baz_role.wont_equal nil
        baz_role.name.must_equal 'baz23'
        baz_role.destroy
        baz_role = nil
        # Check that the deletion worked
        proc { @service.roles.find_by_id foobar_id }.must_raise Fog::OpenStack::Identity::NotFound if foobar_id
        %w[foobar23 baz23].each do |role_name|
          @service.roles.all(:name => role_name).length.must_equal 0
        end
      ensure
        # Delete the roles
        foobar_by_name = @service.roles.all(:name => 'foobar23').first
        foobar_by_name.destroy if foobar_by_name
        baz_by_name = @service.roles.all(:name => 'baz23').first
        baz_by_name.destroy if baz_by_name
      end
    end
  end

  it "lists projects" do
    VCR.use_cassette('idv3_project') do
      projects = @service.projects
      projects.wont_equal nil
      # TO DO: fix along the two other skipped tests
      # projects.length.wont_equal 0

      projects_all = @service.projects.all
      projects_all.wont_equal nil
      projects_all.length.wont_equal 0
      project_byid = @service.projects.find_by_id projects_all.first.id
      project_byid.wont_equal nil

      proc { @service.projects.find_by_id 'atlantis' }.must_raise Fog::OpenStack::Identity::NotFound
    end
  end

  it "CRUD projects" do
    VCR.use_cassette('idv3_project_crud') do
      default_domain = @service.domains.find_by_id @openstack_vcr.domain_id

      begin
        # Create a project called foobar - should not work without domain id?
        foobar_project = @service.projects.create(:name => 'p-foobar46')
        foobar_id = foobar_project.id
        @service.projects.all(:name => 'p-foobar46').length.must_equal 1
        foobar_project.domain_id.must_equal default_domain.id

        # Rename it to baz and disable it (required so we can delete it)
        foobar_project.update(:name => 'p-baz46', :enabled => false)
        foobar_project.name.must_equal 'p-baz46'

        # Read the project freshly and check the name & enabled state
        @service.projects.all(:name => 'p-baz46').length.must_equal 1
        baz_project = @service.projects.find_by_id foobar_id
        baz_project.wont_equal nil
        baz_project.name.must_equal 'p-baz46'
        baz_project.enabled.must_equal false
      ensure
        # Delete the project
        baz_project.destroy

        # Check that the deletion worked
        proc { @service.projects.find_by_id foobar_id }.must_raise Fog::OpenStack::Identity::NotFound
        ['p-foobar46', 'p-baz46'].each do |project_name|
          @service.projects.all(:name => project_name).length.must_equal 0
        end
      end
    end
  end

  it "CRUD & list hierarchical projects" do
    VCR.use_cassette('idv3_project_hier_crud_list') do
      begin
        # Create a project called foobar
        foobar_project = @service.projects.create(:name => 'p-foobar67')
        foobar_id = foobar_project.id

        # Create a sub-project called baz
        baz_project = @service.projects.create(:name => 'p-baz67', :parent_id => foobar_id)
        baz_id = baz_project.id

        baz_project.parent_id.must_equal foobar_id

        # Read the project freshly and check the parent_id
        fresh_baz_project = @service.projects.all(:name => 'p-baz67').first
        fresh_baz_project.wont_equal nil
        fresh_baz_project.parent_id.must_equal foobar_id

        # Create another sub-project called boo
        boo_project = @service.projects.create(:name => 'p-boo67', :parent_id => foobar_id)
        boo_id = boo_project.id

        # Create a sub-project of boo called booboo
        booboo_project = @service.projects.create(:name => 'p-booboo67', :parent_id => boo_id)
        booboo_id = booboo_project.id

        # Make sure we have a role on all these projects (needed for subtree_as_list and parents_as_list)
        prj_role = @service.roles.create(:name => 'r-project67')
        [foobar_project, baz_project, boo_project, booboo_project].each do |project|
          project.grant_role_to_user(prj_role.id, @service.current_user_id)
        end

        # Get the children of foobar, as a tree of IDs
        foobar_kids = @service.projects.find_by_id(foobar_id, :subtree_as_ids).subtree
        foobar_kids.keys.length.must_equal 2

        boo_index = foobar_kids.keys.index boo_id
        boo_index.wont_equal nil

        foobar_child_id = foobar_kids.keys[boo_index]
        foobar_kids[foobar_child_id].length.must_equal 1
        foobar_grandchild_id = foobar_kids[foobar_child_id].keys.first
        foobar_grandchild_id.must_equal booboo_id

        # Get the children of foobar, as a list of objects
        foobar_kids = @service.projects.find_by_id(foobar_id, :subtree_as_list).subtree
        foobar_kids.length.must_equal 3
        [foobar_kids[0].id, foobar_kids[1].id, foobar_kids[2].id].sort.must_equal [baz_id, boo_id, booboo_id].sort

        # Create a another sub-project of boo called fooboo and check that it appears in the parent's subtree
        fooboo_project = @service.projects.create(:name => 'p-fooboo67', :parent_id => boo_id)
        fooboo_id = fooboo_project.id
        fooboo_project.grant_role_to_user(prj_role.id, @service.current_user_id)
        foobar_new_kids = @service.projects.find_by_id(foobar_id, :subtree_as_list).subtree
        foobar_new_kids.length.must_equal 4

        # Get the parents of booboo, as a tree of IDs
        booboo_parents = @service.projects.find_by_id(booboo_id, :parents_as_ids).parents
        booboo_parents.keys.length.must_equal 1
        booboo_parent_id = booboo_parents.keys.first
        booboo_parents[booboo_parent_id].length.must_equal 1
        booboo_grandparent_id = booboo_parents[booboo_parent_id].keys.first
        booboo_grandparent_id.must_equal foobar_id
        assert_nil booboo_parents[booboo_parent_id][booboo_grandparent_id]

        # Get the parents of booboo, as a list of objects
        booboo_parents = @service.projects.find_by_id(booboo_id, :parents_as_list).parents
        booboo_parents.length.must_equal 2
        [booboo_parents[0].id, booboo_parents[1].id].sort.must_equal [foobar_id, boo_id].sort
      ensure
        # Delete the projects
        fooboo_project.destroy if fooboo_project
        booboo_project.destroy if booboo_project
        boo_project.destroy if boo_project
        baz_project.destroy if baz_project
        foobar_project.destroy if foobar_project
        prj_role ||= @service.roles.all(:name => 'r-project67').first
        prj_role.destroy if prj_role
        # Check that the deletion worked
        proc { @service.projects.find_by_id foobar_id }.must_raise Fog::OpenStack::Identity::NotFound if foobar_id
        ['p-booboo67', 'p-fooboo67', 'p-boo67', 'p-baz67', 'p-foobar67'].each do |project_name|
          prj = @service.projects.all(:name => project_name).first
          prj.destroy if prj
          @service.projects.all(:name => project_name).length.must_equal 0
        end
      end
    end
  end

  it "Manipulates projects - add/remove users/groups via role assignment/revocation" do
    VCR.use_cassette('idv3_project_group_user_roles_mutation') do
      # Make sure there is no existing project called foobar
      @service.projects.all(:name => 'p-foobar69').each do |project|
        project.update(:enabled => false)
        project.destroy
      end
      @service.projects.all(:name => 'p-foobar69').length.must_equal 0

      begin
        # Create a project called foobar
        foobar_project = @service.projects.create(:name => 'p-foobar69')
        # Create a role called baz
        @service.roles.all(:name => 'baz').each do |role|
          role.update(:enabled => false)
          role.destroy
        end
        baz_role = @service.roles.create(:name => 'baz69')

        # Create a user
        foobar_user = @service.users.create(:name     => 'u-foobar69',
                                            :email    => 'foobar@example.com',
                                            :password => 's3cret!')

        # Create a group and add the user to it
        foobar_group = @service.groups.create(:name        => 'g-foobar69',
                                              :description => "Group of Foobar users")
        foobar_group.add_user foobar_user.id

        # User has no projects initially
        foobar_user.projects.length.must_equal 0
        @service.role_assignments.all(:user_id    => foobar_user.id,
                                      :project_id => foobar_project.id,
                                      :effective  => true).length.must_equal 0
        foobar_project.user_roles(foobar_user.id).length.must_equal 0

        # Grant role to the user in the new project - this assigns the project to the user
        foobar_project.grant_role_to_user(baz_role.id, foobar_user.id)
        foobar_user.projects.length.must_equal 1
        foobar_project.check_user_role(foobar_user.id, baz_role.id).must_equal true
        foobar_project.user_roles(foobar_user.id).length.must_equal 1

        # Revoke role from the user in the new project - this removes the user from the project
        foobar_project.revoke_role_from_user(baz_role.id, foobar_user.id)
        foobar_user.projects.length.must_equal 0
        foobar_project.check_user_role(foobar_user.id, baz_role.id).must_equal false

        # Group initially has no roles in project
        foobar_project.group_roles(foobar_group.id).length.must_equal 0

        @service.role_assignments.all(:user_id    => foobar_user.id,
                                      :project_id => foobar_project.id,
                                      :effective  => true).length.must_equal 0

        # Grant role to the group in the new project - this assigns the project to the group
        foobar_project.grant_role_to_group(baz_role.id, foobar_group.id)
        foobar_project.check_group_role(foobar_group.id, baz_role.id).must_equal true
        foobar_project.group_roles(foobar_group.id).length.must_equal 1

        # Now we check that a user has the role in that project
        assignments = @service.role_assignments.all(:user_id    => foobar_user.id,
                                                    :project_id => foobar_project.id,
                                                    :effective  => true)
        assignments.length.must_equal 1
        assignments.first.role['id'].must_equal baz_role.id
        assignments.first.user['id'].must_equal foobar_user.id
        assignments.first.scope['project']['id'].must_equal foobar_project.id
        assignments.first.links['assignment'].must_match %r{/v3/projects/#{foobar_project.id}/groups/#{foobar_group.id}/roles/#{baz_role.id}}
        assignments.first.links['membership'].must_match %r{/v3/groups/#{foobar_group.id}/users/#{foobar_user.id}}

        # and we check that the user is in the project because of group membership
        foobar_user.projects.length.must_equal 1

        # Revoke role from the group in the new project - this removes the group from the project
        foobar_project.revoke_role_from_group(baz_role.id, foobar_group.id)
        foobar_user.projects.length.must_equal 0
        foobar_project.check_group_role(foobar_group.id, baz_role.id).must_equal false
      ensure
        # Clean up
        foobar_user.destroy if foobar_user
        foobar_group.destroy if foobar_group
        baz_role.destroy if baz_role
        if foobar_project
          foobar_project.update(:enabled => false)
          foobar_project.destroy
        end
      end
    end
  end

  it "lists services" do
    VCR.use_cassette('idv3_service') do
      services = @service.services
      services.wont_equal nil
      services.length.wont_equal 0

      services_all = @service.services.all
      services_all.wont_equal nil
      services_all.length.wont_equal 0

      some_service = @service.services.find_by_id services_all.first.id
      some_service.wont_equal nil

      proc { @service.services.find_by_id 'atlantis' }.must_raise Fog::OpenStack::Identity::NotFound
    end
  end

  it "CRUD services" do
    VCR.use_cassette('idv3_services_crud') do
      @service.services.all

      begin
        # Create a service called foobar
        foobar_service = @service.services.create(:type => 'volume', :name => 'foobar')
        foobar_id = foobar_service.id
        @service.services.all(:type => 'volume').select { |service| service.name == 'foobar' }.length.must_equal 1

        # Rename it to baz
        foobar_service.update(:name => 'baz')
        foobar_service.name.must_equal 'baz'

        # Read the service freshly and check the name
        @service.services.all.select { |service| service.name == 'baz' }.length.must_equal 1
        baz_service = @service.services.find_by_id foobar_id
        baz_service.wont_equal nil
        baz_service.name.must_equal 'baz'
        baz_service.type.must_equal 'volume'
      ensure
        # Delete the service
        baz_service.destroy if baz_service

        # Check that the deletion worked
        proc { @service.services.find_by_id foobar_id }.must_raise Fog::OpenStack::Identity::NotFound if foobar_id
        @service.services.all.select { |service| %w[foobar baz].include? service.name }.length.must_equal 0
      end
    end
  end

  it "lists endpoints" do
    VCR.use_cassette('idv3_endpoint') do
      endpoints = @service.endpoints
      endpoints.wont_equal nil
      endpoints.length.wont_equal 0

      endpoints_all = @service.endpoints.all
      endpoints_all.wont_equal nil
      endpoints_all.length.wont_equal 0

      some_endpoint = @service.endpoints.find_by_id endpoints_all.first.id
      some_endpoint.wont_equal nil

      proc { @service.endpoints.find_by_id 'atlantis' }.must_raise Fog::OpenStack::Identity::NotFound
    end
  end

  it "CRUD endpoints" do
    VCR.use_cassette('idv3_endpoints_crud') do
      service = @service.services.all.first
      @service.endpoints.all

      begin
        # Create a endpoint called foobar
        foobar_endpoint = @service.endpoints.create(:service_id => service.id,
                                                    :interface  => 'internal',
                                                    :name       => 'foobar',
                                                    :url        => 'http://example.com/foobar',
                                                    :enabled    => false)
        foobar_id = foobar_endpoint.id
        @service.endpoints.all(:interface => 'internal').select do |endpoint|
          endpoint.name == 'foobar'
        end.length.must_equal 1

        # Rename it to baz
        foobar_endpoint.update(:name => 'baz', :url => 'http://example.com/baz')
        foobar_endpoint.name.must_equal 'baz'
        foobar_endpoint.url.must_equal 'http://example.com/baz'

        # Read the endpoint freshly and check the name
        @service.endpoints.all(:interface => 'internal').select do |endpoint|
          endpoint.name == 'baz'
        end.length.must_equal 1
        baz_endpoint = @service.endpoints.find_by_id foobar_id
        baz_endpoint.wont_equal nil
        baz_endpoint.name.must_equal 'baz'
        baz_endpoint.url.must_equal 'http://example.com/baz'
        baz_endpoint.interface.must_equal 'internal'
      ensure
        # Delete the endpoint
        baz_endpoint.destroy

        # Check that the deletion worked
        proc { @service.endpoints.find_by_id foobar_id }.must_raise Fog::OpenStack::Identity::NotFound
        @service.endpoints.all.select { |endpoint| %w[foobar baz].include? endpoint.name }.length.must_equal 0
      end
    end
  end

  it "lists OS credentials" do
    VCR.use_cassette('idv3_credential') do
      credentials = @service.os_credentials
      credentials.wont_equal nil

      credentials_all = @service.os_credentials.all
      credentials_all.wont_equal nil

      proc { @service.os_credentials.find_by_id 'atlantis' }.must_raise Fog::OpenStack::Identity::NotFound
    end
  end

  it "CRUD OS credentials" do
    VCR.use_cassette('idv3_credential_crud') do
      begin
        # Create a user
        foobar_user = @service.users.create(:name     => 'u-foobar_cred',
                                            :email    => 'foobar@example.com',
                                            :password => 's3cret!')
        project = @service.projects.all.first

        access_key = '9c4e774a-f644-498f-90c4-970b3f817fc5'
        secret_key = '7e084117-b13d-4656-9eca-85376b690897'

        # OpenStack Keystone requires the blob to be a JSON string - i.e. not JSON, but a string containing JSON :-/
        blob_json = {:access => access_key,
                     :secret => secret_key}.to_json

        # Make sure there are no existing ec2 credentials
        @service.os_credentials.all.select do |credential|
          credential.type == 'foo' || credential.type == 'ec2'
        end.each(&:destroy)
        @service.os_credentials.all.select do |credential|
          credential.type == 'ec2'
        end.length.must_equal 0

        # Create a credential
        foo_credential = @service.os_credentials.create(:type       => 'ec2',
                                                        :project_id => project.id,
                                                        :user_id    => foobar_user.id,
                                                        :blob       => blob_json)
        credential_id = foo_credential.id
        @service.os_credentials.all.select { |credential| credential.type == 'ec2' }.length.must_equal 1

        # Update secret key
        new_secret_key = '62307bcd-ca3c-47ae-a114-27a6cadb5bc9'
        new_blob_json = {:access => access_key,
                         :secret => new_secret_key}.to_json
        foo_credential.update(:blob => new_blob_json)
        JSON.parse(foo_credential.blob)['secret'].must_equal new_secret_key

        # Read the credential freshly and check the secret key
        @service.os_credentials.all.select { |credential| credential.type == 'ec2' }.length.must_equal 1
        updated_credential = @service.os_credentials.find_by_id credential_id
        updated_credential.wont_equal nil
        updated_credential.type.must_equal 'ec2'
        JSON.parse(updated_credential.blob)['secret'].must_equal new_secret_key
      ensure
        foobar_user ||= @service.users.find_by_name('u-foobar_cred').first
        foobar_user.destroy if foobar_user
        # Delete the credential
        begin
          updated_credential.destroy if updated_credential
          foo_credential.destroy if foo_credential
        rescue
          false
        end

        # Check that the deletion worked
        if credential_id
          proc { @service.os_credentials.find_by_id credential_id }.must_raise Fog::OpenStack::Identity::NotFound
        end
        @service.os_credentials.all.select { |credential| credential.type == 'ec2' }.length.must_equal 0
      end
    end
  end

  it "lists policies" do
    VCR.use_cassette('idv3_policy') do
      policies = @service.policies
      policies.wont_equal nil
      policies.length.must_equal 0

      policies_all = @service.policies.all
      policies_all.wont_equal nil
      policies_all.length.must_equal 0

      proc { @service.policies.find_by_id 'atlantis' }.must_raise Fog::OpenStack::Identity::NotFound
    end
  end

  it "CRUD policies" do
    VCR.use_cassette('idv3_policy_crud') do
      blob = {'foobar_user' => ['role:compute-user']}.to_json

      # Make sure there are no existing policies
      @service.policies.all.select { |policy| policy.type == 'application/json' }.length.must_equal 0

      # Create a policy
      foo_policy = @service.policies.create(:type => 'application/json',
                                            :blob => blob)
      policy_id = foo_policy.id
      @service.policies.all.select { |policy| policy.type == 'application/json' }.length.must_equal 1

      # Update policy blob
      new_blob = {'baz_user' => ['role:compute-user']}.to_json
      foo_policy.update(:blob => new_blob)
      foo_policy.blob.must_equal new_blob

      # Read the policy freshly and check the secret key
      @service.policies.all.select { |policy| policy.type == 'application/json' }.length.must_equal 1
      updated_policy = @service.policies.find_by_id policy_id
      updated_policy.wont_equal nil
      updated_policy.type.must_equal 'application/json'
      updated_policy.blob.must_equal new_blob

      # Delete the policy
      updated_policy.destroy

      # Check that the deletion worked
      proc { @service.policies.find_by_id policy_id }.must_raise Fog::OpenStack::Identity::NotFound
      @service.policies.all.select { |policy| policy.type == 'application/json' }.length.must_equal 0
    end
  end
end
