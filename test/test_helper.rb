# TODO: remove when https://github.com/fog/fog-openstack/issues/202 is fixed
# require 'coveralls'
# Coveralls.wear!

require 'minitest/autorun'
require "minitest/spec"
require 'fog/core'
require 'fog/test_helpers/types_helper.rb'
require 'fog/test_helpers/minitest/assertions'
require 'fog/test_helpers/minitest/expectations'

require File.expand_path('../../lib/fog/openstack', __FILE__)

# Load all service specific Mock classes
require File.expand_path('../../test/lib/fog/identity/openstack', __FILE__)
require File.expand_path('../../test/lib/fog/identity/openstack/v2', __FILE__)
require File.expand_path('../../test/lib/fog/identity/openstack/v3', __FILE__)
require File.expand_path('../../test/lib/fog/network/openstack', __FILE__)

Fog.mock! if ENV["FOG_MOCK"] == "true"
Bundler.require(:test)

Excon.defaults.merge!(:debug_request => true, :debug_response => true)

require File.expand_path(File.join(File.dirname(__FILE__), 'helpers', 'mock_helper'))

# This overrides the default 600 seconds timeout during live test runs
unless Fog.mocking?
  Fog.timeout = ENV['FOG_TEST_TIMEOUT'] || 2_000
  Fog::Logger.warning "Setting default fog timeout to #{Fog.timeout} seconds"
end

def lorem_file
  File.open(File.dirname(__FILE__) + '/lorem.txt', 'r')
end

def array_differences(array_a, array_b)
  (array_a - array_b) | (array_b - array_a)
end

module Minitest
  class Test
    # Some tests need to be fixed. There are skipped unless the following is true
    UNIT_TESTS_CLEAN = false
  end
end
