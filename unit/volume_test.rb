require 'test_helper'
require 'fog/openstack'

describe Fog::OpenStack::Volume do
  describe '.new' do
    # Each versioned service resolves a different catalog entry, and raises a
    # ServiceTypeError when the catalog does not advertise it. Stub the versions
    # out so the negotiation itself can be tested without a token endpoint: the
    # +catalog+ hash carries a marker for the versions the catalog knows about,
    # and nil for the rest.
    def with_catalog(catalog, &block)
      missing = lambda do |*_args|
        raise Fog::OpenStack::Auth::Catalog::ServiceTypeError, 'No endpoint match'
      end
      responder = ->(marker) { marker ? ->(*_args) { marker } : missing }

      Fog::OpenStack::Volume::V3.stub(:new, responder.call(catalog[:volumev3])) do
        Fog::OpenStack::Volume::V2.stub(:new, responder.call(catalog[:volumev2])) do
          Fog::OpenStack::Volume::V1.stub(:new, responder.call(catalog[:volume]), &block)
        end
      end
    end

    it 'prefers V3 when the catalog advertises volumev3' do
      with_catalog(:volumev3 => :v3, :volumev2 => :v2, :volume => :v1) do
        _(Fog::OpenStack::Volume.new).must_equal :v3
      end
    end

    it 'falls back to V2 when volumev3 is missing' do
      with_catalog(:volumev2 => :v2, :volume => :v1) do
        _(Fog::OpenStack::Volume.new).must_equal :v2
      end
    end

    it 'falls back to V1 when only volume is advertised' do
      with_catalog(:volume => :v1) do
        _(Fog::OpenStack::Volume.new).must_equal :v1
      end
    end

    it 're-raises when the catalog advertises no volume service at all' do
      with_catalog({}) do
        _(proc { Fog::OpenStack::Volume.new }).must_raise(
          Fog::OpenStack::Auth::Catalog::ServiceTypeError
        )
      end
    end
  end
end
