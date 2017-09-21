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
  name = File.dirname(__FILE__) + '/lorem.txt'
  if not File.file?(name)
    f = File.open(name, 'w')
    f.write(
        "Lorem ipsum dolor sit amet, no partem signiferumque vix, feugiat "\
        "oporteat inciderint an sit, porro oratio concludaturque an vim. Mel "\
        "commodo eripuit id, ei amet detraxit nec. Duo legendos constituam "\
        "delicatissimi no, dolor legere ne vix, eros disputationi at per." \
        "Lucilius perfecto cum an, vel et dicat accommodare, minim reformidans eu" \
        "sed. Has veri novum dissentiunt id, melius dissentiunt eum id. Quo no" \
        "vidisse nusquam rationibus, usu ut veri choro. Ex eligendi suscipit nec," \
        "falli putant vim eu, vix assum graecis reprehendunt ad." \
        "" \
        "Has ipsum patrioque evertitur an, vis facete admodum ex, an qui posse" \
        "erant nihil. Nam sonet salutandi ad, cum oblique disputando et. Ne" \
        "melius veritus vocibus quo, debet eruditi cu mel. Elitr aperiri atomorum" \
        "et eum." \
        "" \
        "Sea electram prodesset te. Invidunt principes mea in. Natum oblique" \
        "assueverit ea mea, eos ut solum nullam, an pro simul clita impetus. Per" \
        "apeirian dissentiunt ne, feugait maluisset reprehendunt cu his. Cu" \
        "gubergren aliquando moderatius mei, mei saepe impedit ut." \
        "" \
        "Te mea facilisis cotidieque definitiones, has illum ullum sensibus id," \
        "in meliore minimum assentior duo. Ne nec cibo sadipscing mediocritatem," \
        "lorem fabellas lobortis ut vim, noluisse consetetur temporibus pri ut." \
        "Qui no nibh appareat delicata, id vis integre debitis, sed probo" \
        "probatus eu. Vel dicat debet ancillae at, lorem debet ponderum eu cum." \
        "An sea case affert, option graecis duo ea. Vivendum legendos eum eu." \
        "" \
        "Et est inani dolore, dicta prodesset qui ne. Inermis veritus fierent mei" \
        "no, sit in amet reque philosophia. Erant docendi sit ne. His id" \
        "petentium periculis. Veri efficiendi no has, id vix quas eripuit" \
        "temporibus.")
    f.close
  end
  File.open(File.dirname(__FILE__) + '/lorem.txt', 'r')
end

def array_differences(array_a, array_b)
  (array_a - array_b) | (array_b - array_a)
end

def prefix_with_url(files, base_url)
  files.map { |fname| File.join(base_url.to_s, fname) }.compact
end

def assert_equal_set(a, b)
  assert_equal(Set.new(a), Set.new(b))
end

module Minitest
  class Test
    # Some tests need to be fixed. There are skipped unless the following is true
    UNIT_TESTS_CLEAN = false
  end
end
