require 'spec_helper'

require 'fog/openstack/compute/requests/enable_service'
require 'fog/openstack/storage/requests/delete_multiple_objects'
require 'fog/openstack/workflow/v2/requests/get_action'

# Builds a Real instance without running its initializer (which would need
# credentials and a live endpoint) and captures what it hands to #request.
def capture_request(klass, response_body = '{}')
  instance = klass.allocate
  captured = nil
  instance.define_singleton_method(:request) do |params, *_args|
    captured = params
    Excon::Response.new(:body => response_body)
  end
  yield instance
  captured
end

describe 'URL escaping' do
  describe 'Fog::OpenStack.escape' do
    # This is why these call sites cannot use CGI.escape: in a URL *path* a
    # '+' is a literal plus, not a space, so CGI.escape corrupts any name
    # containing a space.
    it 'encodes a space as %20 rather than +' do
      assert_equal 'sp%20ace', Fog::OpenStack.escape('sp ace')
      assert_equal 'sp+ace', CGI.escape('sp ace')
    end

    it 'leaves unreserved characters alone' do
      assert_equal 'name-with.dots_and-dashes', Fog::OpenStack.escape('name-with.dots_and-dashes')
    end

    it 'escapes a slash by default but can be told to keep it' do
      assert_equal 'a%2Fb', Fog::OpenStack.escape('a/b')
      assert_equal 'a/b', Fog::OpenStack.escape('a/b', '/')
    end
  end

  describe 'Workflow::V2 resource names in the path' do
    it 'escapes the name into a single path segment' do
      captured = capture_request(Fog::OpenStack::Workflow::V2::Real) do |real|
        real.get_action('my action')
      end
      assert_equal 'actions/my%20action', captured[:path]
    end

    it 'escapes a slash inside the name so it cannot forge a path segment' do
      captured = capture_request(Fog::OpenStack::Workflow::V2::Real) do |real|
        real.get_action('a/b')
      end
      assert_equal 'actions/a%2Fb', captured[:path]
    end
  end

  describe 'Storage#delete_multiple_objects' do
    it 'escapes each name but keeps the container/object separator intact' do
      captured = capture_request(Fog::OpenStack::Storage::Real) do |real|
        real.delete_multiple_objects('my container', ['some object', 'plain'])
      end
      assert_equal "my%20container/some%20object\nmy%20container/plain", captured[:body]
    end

    it 'escapes bare names when no container is given' do
      captured = capture_request(Fog::OpenStack::Storage::Real) do |real|
        real.delete_multiple_objects(nil, ['some object'])
      end
      assert_equal 'some%20object', captured[:body]
    end
  end

  describe 'Compute service optional params' do
    it 'escapes the values' do
      captured = capture_request(Fog::OpenStack::Compute::Real) do |real|
        real.enable_service('host1', 'nova-compute', 'reason' => 'out of service')
      end
      assert_equal({'reason' => 'out%20of%20service'}, captured[:query])
    end

    it 'does not mutate the hash the caller passed in' do
      params = {'reason' => 'out of service'}
      capture_request(Fog::OpenStack::Compute::Real) do |real|
        real.enable_service('host1', 'nova-compute', params)
      end
      assert_equal({'reason' => 'out of service'}, params)
    end
  end

  describe 'the whole library' do
    it 'no longer calls URI.encode or URI.escape, removed in Ruby 3.0' do
      lib = File.expand_path('../lib', __dir__)
      offenders = Dir.glob("#{lib}/**/*.rb").select do |file|
        File.read(file).match?(/\bURI\.(encode|escape)\b/)
      end
      assert_empty(offenders.map { |f| f.sub("#{lib}/", '') })
    end
  end
end
