require "test_helper"

describe "Fog::Storage[:openstack] | container requests" do
  before do
    @storage = Fog::Storage[:openstack]
    @container_format = [String]

    @containers_format = [{
      'bytes' => Integer,
      'count' => Integer,
      'name'  => String
    }]
  end

  describe "success" do
    it "#put_container('fogcontainertests')" do
      skip if Fog.mocking?
      @storage.put_container('fogcontainertests').status.must_equal 202
    end

    it "#get_container('fogcontainertests')" do
      skip if Fog.mocking?
      @storage.get_container('fogcontainertests').body.
        must_match_schema(@container_format)
    end

    it "#get_containers" do
      skip if Fog.mocking?
      @storage.get_containers.body.
        must_match_schema(@containers_format)
    end

    it "#head_container('fogcontainertests')" do
      skip if Fog.mocking?
      @storage.head_container('fogcontainertests').status.must_equal 202
    end

    it "#head_containers" do
      skip if Fog.mocking?
      @storage.head_containers.status.must_equal 202
    end

    it "#delete_container('fogcontainertests')" do
      skip if Fog.mocking?
      @storage.delete_container('fogcontainertests').status.must_equal 202
    end
  end

  describe "failure" do
    it "#get_container('fognoncontainer')" do
      skip if Fog.mocking?
      proc do
        @storage.get_container('fognoncontainer')
      end.must_raise Fog::Storage::OpenStack::NotFound
    end

    it "#head_container('fognoncontainer')" do
      skip if Fog.mocking?
      proc do
        @storage.head_container('fognoncontainer')
      end.must_raise Fog::Storage::OpenStack::NotFound
    end

    it "#delete_container('fognoncontainer')" do
      skip if Fog.mocking?
      proc do
        @storage.delete_container('fognoncontainer')
      end.must_raise Fog::Storage::OpenStack::NotFound
    end
  end
end
