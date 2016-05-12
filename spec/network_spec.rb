require 'spec_helper'
require_relative './shared_context'

describe Fog::Network::OpenStack do
  before :all do
    openstack_vcr = OpenStackVCR.new(
      :vcr_directory  => 'spec/fixtures/openstack/network',
      :service_class  => Fog::Network::OpenStack,
      :project_scoped => true
    )
    @service          = openstack_vcr.service
    @current_project  = openstack_vcr.project_name

    openstack_vcr = OpenStackVCR.new(
      :vcr_directory => 'spec/fixtures/openstack/network',
      :service_class => Fog::Identity::OpenStack::V3
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
        other_project = @identity_service.projects.select { |p| p.name != @current_project }.first

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
end
