require "test_helper"

def test_temp_url(url_s, time, desired_scheme)
  object_url = URI.parse(url_s)
  query_params = URI.decode_www_form(object_url.query)

  it "the link returns #{desired_scheme}" do
    desired_scheme.must_equal { object_url.scheme }
  end

  it "the container and object are present in the path" do
    (object_url.path =~ %r{/#{@directory.identity}/fog_object}).nil?
  end

  it "a temp_url_sig is present" do
    assert do
      query_params.any? { |p| p[0] == 'temp_url_sig' }
    end
  end

  it "temp_url_expires matches the expiration" do
    assert do
      query_params.any? { |p| p == ['temp_url_expires', time.to_i.to_s] }
    end
  end
end

describe "Fog::Storage[:openstack] | object requests" do
  before do
    unless Fog.mocking?
      @directory = Fog::Storage[:openstack].directories.create(:key => 'fogobjecttests')
    end

    module OpenStackStorageHelpers
      def override_path(path)
        @path = path
      end
    end
  end

  after do
    unless Fog.mocking?
      @directory.destroy
    end
  end

  describe "success" do
    it "#put_object('fogobjecttests', 'fog_object')" do
      skip if Fog.mocking?
      Fog::Storage[:openstack].put_object('fogobjecttests', 'fog_object', lorem_file)
    end

    it "#get_object('fogobjectests', 'fog_object')" do
      skip if Fog.mocking?
      Fog::Storage[:openstack].get_object('fogobjecttests', 'fog_object').body == lorem_file.read
    end

    it "#get_object('fogobjecttests', 'fog_object', &block)" do
      skip if Fog.mocking?
      data = ''
      Fog::Storage[:openstack].get_object('fogobjecttests', 'fog_object') do |chunk, _remaining_bytes, _total_bytes|
        data << chunk
      end
      data == lorem_file.read
    end

    it "#public_url('fogobjectests', 'fog_object')" do
      skip if Fog.mocking?
      Fog::Storage[:openstack].directories.first.files.first.public_url
    end

    it "#public_url('fogobjectests')" do
      skip if Fog.mocking?
      Fog::Storage[:openstack].directories.first.public_url
    end

    it "#head_object('fogobjectests', 'fog_object')" do
      skip if Fog.mocking?
      Fog::Storage[:openstack].head_object('fogobjecttests', 'fog_object')
    end

    it "#delete_object('fogobjecttests', 'fog_object')" do
      skip if Fog.mocking?
      Fog::Storage[:openstack].delete_object('fogobjecttests', 'fog_object')
    end

    it "#get_object_http_url('directory.identity', 'fog_object', expiration timestamp)" do
      skip if Fog.mocking?
      ts = Time.at(1_395_343_213)
      url_s = Fog::Storage[:openstack].get_object_http_url(@directory.identity, 'fog_object', ts)
      test_temp_url(url_s, ts, 'http')
    end

    it "#get_object_https_url('directory.identity', 'fog_object', expiration timestamp)" do
      skip if Fog.mocking?
      ts = Time.at(1_395_343_213)
      url_s = Fog::Storage[:openstack].get_object_https_url(@directory.identity, 'fog_object', ts)
      test_temp_url(url_s, ts, 'https')
    end

    describe "put_object with block" do
      it "#put_object('fogobjecttests', 'fog_object', &block)" do
        skip if Fog.mocking?
        begin
          file = lorem_file
          buffer_size = file.stat.size / 2 # chop it up into two buffers
          Fog::Storage[:openstack].put_object('fogobjecttests', 'fog_block_object', nil) do
            file.read(buffer_size).to_s
          end
        ensure
          file.close
        end
      end

      it "#get_object" do
        skip if Fog.mocking?
        Fog::Storage[:openstack].get_object('fogobjecttests', 'fog_block_object').body == lorem_file.read
      end

      it "#delete_object" do
        skip if Fog.mocking?
        Fog::Storage[:openstack].delete_object('fogobjecttests', 'fog_block_object')
      end
    end

    describe "deletes multiple objects" do
      before do
        unless Fog.mocking?
          Fog::Storage[:openstack].put_object('fogobjecttests', 'fog_object', lorem_file)
          Fog::Storage[:openstack].put_object('fogobjecttests', 'fog_object2', lorem_file)
          Fog::Storage[:openstack].directories.create(:key => 'fogobjecttests2')
          Fog::Storage[:openstack].put_object('fogobjecttests2', 'fog_object', lorem_file)
        end

        @expected = {
          "Number Not Found" => 0,
          "Response Status"  => "200 OK",
          "Errors"           => [],
          "Number Deleted"   => 2,
          "Response Body"    => ""
        }
      end

      it "#delete_multiple_objects" do
        skip if Fog.mocking?
        Fog::Storage[:openstack].delete_multiple_objects('fogobjecttests',
                                                         %w[fog_object, fog_object2]
                                                        ).body == @expected
      end

      it "deletes object and container" do
        skip if Fog.mocking?
        Fog::Storage[:openstack].delete_multiple_objects(
          nil,
          ['fogobjecttests2/fog_object', 'fogobjecttests2']
        ).body == @expected
      end
    end
  end

  describe "failure" do
    it "#get_object('fogobjecttests', 'fog_non_object')" do
      skip if Fog.mocking?
      proc do
        Fog::Storage[:openstack].get_object('fogobjecttests', 'fog_non_object')
      end.must_raise(Fog::Storage::OpenStack::NotFound)
    end

    it "#get_object('fognoncontainer', 'fog_non_object')" do
      skip if Fog.mocking?
      proc do
        Fog::Storage[:openstack].get_object('fognoncontainer', 'fog_non_object')
      end.must_raise(Fog::Storage::OpenStack::NotFound)
    end

    it "#head_object('fogobjecttests', 'fog_non_object')" do
      skip if Fog.mocking?
      proc do
        Fog::Storage[:openstack].head_object('fogobjecttests', 'fog_non_object')
      end.must_raise(Fog::Storage::OpenStack::NotFound)
    end

    it "#head_object('fognoncontainer', 'fog_non_object')" do
      skip if Fog.mocking?
      proc do
        Fog::Storage[:openstack].head_object('fognoncontainer', 'fog_non_object')
      end.must_raise(Fog::Storage::OpenStack::NotFound)
    end

    it "#delete_object('fogobjecttests', 'fog_non_object')" do
      skip if Fog.mocking?
      proc do
        Fog::Storage[:openstack].delete_object('fogobjecttests', 'fog_non_object')
      end.must_raise(Fog::Storage::OpenStack::NotFound)
    end

    it "#delete_object('fognoncontainer', 'fog_non_object')" do
      skip if Fog.mocking?
      proc do
        Fog::Storage[:openstack].delete_object('fognoncontainer', 'fog_non_object')
      end.must_raise(Fog::Storage::OpenStack::NotFound)
    end

    describe "#delete_multiple_objects" do
      before do
        @expected = {
          "Number Not Found" => 2,
          "Response Status"  => "200 OK",
          "Errors"           => [],
          "Number Deleted"   => 0,
          "Response Body"    => ""
        }
      end

      it "reports missing objects" do
        skip if Fog.mocking?
        Fog::Storage[:openstack].delete_multiple_objects('fogobjecttests',
                                                        %w[fog_non_object, fog_non_object2]
                                                        ).body == @expected
      end

      it "reports missing container" do
        skip if Fog.mocking?
        Fog::Storage[:openstack].delete_multiple_objects('fognoncontainer',
                                                         %w[fog_non_object, fog_non_object2]
                                                        ).body == @expected
      end

      it "deleting non-empty container" do
        skip if Fog.mocking?
        Fog::Storage[:openstack].put_object('fogobjecttests', 'fog_object', lorem_file)

        expected = {
          "Number Not Found" => 0,
          "Response Status"  => "400 Bad Request",
          "Errors"           => [['fogobjecttests', '409 Conflict']],
          "Number Deleted"   => 1,
          "Response Body"    => ""
        }

        Fog::Storage[:openstack].delete_multiple_objects(
          nil,
          %w[fogobjecttests, fogobjecttests/fog_object]
        ).body == expected
      end
    end
  end
end
