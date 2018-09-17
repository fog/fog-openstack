require 'test_helper'
require "helpers/network_helper"

describe 'Fog::OpenStack::Network | subnet_pools' do
  describe 'success' do
    before do
      @subnet_pool = network.subnet_pools.create(
        :name              => 'fog_subnetpool',
        :prefixes          => ['10.0.0.0/16'],
        :description       => 'fog_subnetpool_description',
        :min_prefixlen     => 64,
        :max_prefixlen     => 64,
        :default_prefixlen => 64
      )

      @subnet_pools = network.subnet_pools
    end

    after do
      @subnet_pool.destroy
    end

    it '#all' do
      @subnet_pools.all[0].id.wont_be_empty
    end

    it '#get' do
      @subnet_pools.get(@subnet_pool.id).id.wont_be_empty
    end
  end
end
