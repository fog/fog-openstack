require 'spec_helper'
require_relative './shared_context'

describe Fog::Network::OpenStack do
  before :all do
    openstack_vcr = OpenStackVCR.new(
      :vcr_directory => 'spec/fixtures/openstack/network',
      :service_class => Fog::Network::OpenStack,
    )
    @service = openstack_vcr.service
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
end
