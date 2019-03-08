require "test_helper"

describe "Fog::OpenStack::Storage | container requests" do
  def cleanup_container
    return if Fog.mocking?
    if @storage.head_container(@container_name)
      @storage.delete_container(@container_name)
    end
  rescue Fog::OpenStack::Storage::NotFound
  end

  before do
    @storage = Fog::OpenStack::Storage.new
    @container_format = [String]
    @container_name = 'fogcontainertests'

    cleanup_container

    @containers_format = [{
      'bytes' => Integer,
      'count' => Integer,
      'name'  => String
    }]
  end

  after do
    cleanup_container
  end

  describe "success" do
    it "#put_container('fogcontainertests')" do
      unless Fog.mocking?
        @storage.put_container('fogcontainertests').status.must_equal 201
      end
    end

    describe "using container" do
      before do
        unless Fog.mocking?
          @storage.put_container(@container_name).status.must_equal 201
        end
      end

      after do
        cleanup_container
      end

      it "#get_container('fogcontainertests')" do
        unless Fog.mocking?
          @storage.get_container('fogcontainertests').body.must_match_schema(@container_format)
        end
      end

      it "#get_containers" do
        unless Fog.mocking?
          @storage.get_containers.body.must_match_schema(@containers_format)
        end
      end

      it "#head_container('fogcontainertests')" do
        unless Fog.mocking?
          resp = @storage.head_container('fogcontainertests')
          resp.status.must_equal 204
          resp.headers['X-Container-Object-Count'].to_i.must_equal 0
        end
      end

      it "#head_containers" do
        unless Fog.mocking?
          resp = @storage.head_containers
          resp.status.must_equal 204
          resp.headers['X-Account-Container-Count'].to_i.must_equal 1
        end
      end
      it "#delete_container('fogcontainertests')" do
        unless Fog.mocking?
          @storage.delete_container('fogcontainertests').status.must_equal 204
        end
      end
    end
  end

  describe "failure" do
    it "#get_container('fognoncontainer')" do
      unless Fog.mocking?
        proc do
          @storage.get_container('fognoncontainer')
        end.must_raise Fog::OpenStack::Storage::NotFound
      end
    end

    it "#head_container('fognoncontainer')" do
      unless Fog.mocking?
        proc do
          @storage.head_container('fognoncontainer')
        end.must_raise Fog::OpenStack::Storage::NotFound
      end
    end

    it "#delete_container('fognoncontainer')" do
      unless Fog.mocking?
        proc do
          @storage.delete_container('fognoncontainer')
        end.must_raise Fog::OpenStack::Storage::NotFound
      end
    end
  end
end
