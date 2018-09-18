require 'spec_helper'
require_relative './shared_context'

describe Fog::OpenStack::Network do
  before :all do
    openstack_vcr = OpenStackVCR.new(
      :vcr_directory  => 'spec/fixtures/openstack/network',
      :service_class  => Fog::OpenStack::Network,
      :project_scoped => true
    )
    @service          = openstack_vcr.service
    @current_project  = openstack_vcr.project_name

    openstack_vcr = OpenStackVCR.new(
      :vcr_directory => 'spec/fixtures/openstack/network',
      :service_class => Fog::OpenStack::Identity::V3
    )
    @identity_service = openstack_vcr.service
  end

  it 'CRUD subnets' do
    VCR.use_cassette('subnets_crud') do
      begin
        foonet = @service.networks.create(:name => 'foo-net12', :shared => false)
        subnet = @service.subnets.create(
          :name       => "my-network",
          :network_id => foonet.id,
          :cidr       => '172.16.0.0/16',
          :ip_version => 4,
          :gateway_ip => nil
        )
        subnet.name.must_equal 'my-network'
      ensure
        subnet.destroy if subnet
        foonet.destroy if foonet
      end
    end
  end

  it 'CRUD rbacs' do
    VCR.use_cassette('rbacs_crud') do
      begin
        own_project   = @identity_service.projects.select { |p| p.name == @current_project }.first
        other_project = @identity_service.projects.reject { |p| p.name == @current_project }.first

        foonet = @service.networks.create(:name => 'foo-net23', :tenant_id => own_project.id)
        # create share access for other project
        rbac = @service.rbac_policies.create(
          :object_type   => 'network',
          :object_id     => foonet.id,
          :tenant_id     => own_project.id,
          :target_tenant => other_project.id,
          :action        => 'access_as_shared'
        )
        rbac.target_tenant.must_equal other_project.id
        foonet.reload.shared.must_equal false
        @service.rbac_policies.all(:object_id => foonet.id).length.must_equal 1

        # get
        @service.rbac_policies.find_by_id(rbac.id).wont_equal nil

        # change share target to own project
        rbac.target_tenant = own_project.id
        rbac.save
        foonet.reload.shared.must_equal true

        # delete the sharing
        rbac.destroy
        rbac = nil
        @service.rbac_policies.all(:object_id => foonet.id).length.must_equal 0
        foonet.reload.shared.must_equal false
      ensure
        rbac.destroy if rbac
        foonet.destroy if foonet
      end
    end
  end

  it 'fails at token expiration on auth with token but not with username+password' do
    VCR.use_cassette('token_expiration') do
      @auth_token = @identity_service.credentials[:openstack_auth_token]
      openstack_vcr = OpenStackVCR.new(
        :vcr_directory  => 'spec/fixtures/openstack/network',
        :service_class  => Fog::OpenStack::Network,
        :project_scoped => true,
        :token_auth     => true,
        :token          => @auth_token
      )
      @service_with_token = openstack_vcr.service

      [@service_with_token, @service].each_with_index do |service, index|
        @network_token = service.credentials[:openstack_auth_token]
        # any network object would do, take sec group - at least we have a default
        @before = service.security_groups.all(:limit => 2).first.tenant_id
        # invalidate the token, hopefully it is not a palindrome
        # NOTE: token_revoke does not work here, because of neutron keystone-middleware cache
        service.instance_variable_set("@auth_token", @network_token.reverse)
        # with token
        if index == 0
          err = -> { service.security_groups.all(:limit => 2) }.must_raise Excon::Errors::Unauthorized
          err.message.must_match(/Authentication required/)
        # with username+password
        else
          @after = service.security_groups.all(:limit => 2).first.tenant_id
          @before.must_equal @after
        end
      end
    end
  end
end
