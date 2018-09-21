require "test_helper"
require "helpers/model_helper"

unless Fog.mocking?
  def object_attributes(file = @instance)
    @instance.service.head_object(@directory.key, file.key).headers
  end

  def object_meta_attributes
    @instance.service.head_object(
      @directory.key,
      @instance.key
    ).headers.reject { |k, _| !(k =~ /X-Object-Meta-/) }
  end

  def clear_metadata
    @instance.metadata.tap do |metadata|
      metadata.each_pair { |k, _| metadata[k] = nil }
    end
  end

  @file_attributes = {
    :key  => 'fog_file_tests',
    :body => lorem_file
  }

  directory_attributes = {
    # Add a random suffix to prevent collision
    :key => "fogfilestests-#{rand(65536)}"
  }

  @directory = Fog::OpenStack::Storage.new.directories.create(directory_attributes)

  describe "Fog::OpenStack::Storage | file" do
    after do
      @directory.destroy
    end

    model_tests(@directory.files, @file_attributes.merge(:etag => 'foo'), Fog.mocking?) do
      it "#save should not blow up with etag" do
        @instance.save
      end
    end

    model_tests(@directory.files, @file_attributes, Fog.mocking?) do
      it "#metadata should load empty metadata" do
        @instance.metadata.must_equal {}
      end

      describe "#save" do
        it "#metadata" do
          before do
            @instance.metadata[:foo] = 'bar'
            @instance.save
          end

          after do
            clear_metadata
            @instance.save
          end

          it "should update metadata" do
            object_meta_attributes['X-Object-Meta-Foo'].must_equal 'bar'
          end

          it "should cache metadata" do
            @instance.metadata[:foo].must_equal 'bar'
          end

          it "should remove empty metadata" do
            @instance.metadata[:foo] = nil
            @instance.save
            object_meta_attributes.must_equal {}
          end
        end

        describe "#cache_control" do
          before do
            @instance = @directory.files.create(
              :key           => 'meta-test',
              :body          => lorem_file,
              :cache_control => 'public, max-age=31536000'
            )
          end

          after do
            clear_metadata
            @instance.save
          end

          it "sets Cache-Control on create" do
            object_attributes(@instance)["Cache-Control"].must_equal "public, max-age=31536000"
          end
        end

        describe "#content_disposition" do
          before do
            @instance = @directory.files.create(
              :key                 => 'meta-test',
              :body                => lorem_file,
              :content_disposition => 'ho-ho-ho'
            )
          end

          after do
            clear_metadata
            @instance.save
          end

          it "sets Content-Disposition on create" do
            object_attributes(@instance)["Content-Disposition"].must_equal "ho-ho-ho"
          end
        end

        describe "#metadata keys" do
          after do
            clear_metadata
            @instance.save
          end

          it "should support compound key names" do
            @instance.metadata[:foo_bar] = 'baz'
            @instance.save
            object_meta_attributes['X-Object-Meta-Foo-Bar'].must_equal 'baz'
          end

          it "should support string keys" do
            @instance.metadata['foo'] = 'bar'
            @instance.save
            object_meta_attributes['X-Object-Meta-Foo'].must_equal 'bar'
          end

          it "should support compound string key names" do
            @instance.metadata['foo_bar'] = 'baz'
            @instance.save
            object_meta_attributes['X-Object-Meta-Foo-Bar'].must_equal 'baz'
          end

          it "should support hyphenated keys" do
            @instance.metadata['foo-bar'] = 'baz'
            @instance.save
            object_meta_attributes['X-Object-Meta-Foo-Bar'].must_equal 'baz'
          end

          it "should only support one value per metadata key" do
            @instance.metadata['foo-bar'] = 'baz'
            @instance.metadata[:foo_bar] = 'bref'
            @instance.save
            object_meta_attributes['X-Object-Meta-Foo-Bar'].must_equal 'bref'
          end
        end
      end

      describe "#access_control_allow_origin" do
        it "#access_control_allow_origin should default to nil" do
          @instance.access_control_allow_origin.must_equal nil
        end

        @instance.access_control_allow_origin = 'http://example.com'
        @instance.save
        it "#access_control_allow_origin should return access control attribute" do
          @instance.access_control_allow_origin.must_equal 'http://example.com'
        end

        @instance.access_control_allow_origin = 'foo'
        @instance.save
        it "#access_control_allow_origin= should update access_control_allow_origin" do
          @instance.access_control_allow_origin = 'bar'
          @instance.save
          @instance.access_control_allow_origin.must_equal 'bar'
        end

        it "#access_control_allow_origin= should not blow up on nil" do
          @instance.access_control_allow_origin = nil
          @instance.save
        end
      end

      describe "#delete_at" do
        @delete_at_time = (Time.now + 300).to_i

        it "#delete_at should default to nil" do
          @instance.delete_at.must_equal nil
        end

        @instance.delete_at = @delete_at_time
        @instance.save
        it "#delete_at should return delete_at attribute" do
          @instance.delete_at.must_equal @delete_at_time
        end

        @instance.delete_at = @delete_at_time
        @instance.save
        it "#delete_at= should update delete_at" do
          @instance.delete_at = @delete_at_time + 100
          @instance.save
          @instance.delete_at.must_equal(@delete_at_time + 100)
        end

        it "#delete_at= should not blow up on nil" do
          @instance.delete_at = nil
          @instance.save
        end
      end
    end

    model_tests(@directory.files, @file_attributes, Fog.mocking?) do
      describe "#origin" do
        it "#origin should default to nil" do
          @instance.save
          @instance.origin.must_equal nil
        end

        @instance.origin = 'http://example.com'
        @instance.save
        it "#origin should return access control attributes" do
          @instance.origin.must_equal('http://example.com')
        end
        @instance.attributes.delete('Origin')

        @instance.origin = 'foo'
        @instance.save
        it "#origin= should update origin" do
          @instance.origin = 'bar'
          @instance.save
          @instance.origin.must_equal 'bar'
        end

        it "#origin= should not blow up on nil" do
          @instance.origin = nil
          @instance.save
        end
      end

      describe "#content_encoding" do
        it "#content_encoding should default to nil" do
          @instance.save
          @instance.content_encoding.must_equal nil
        end

        @instance.content_encoding = 'gzip'
        @instance.save
        it "#content_encoding should return the content encoding" do
          @instance.content_encoding.must_equal 'gzip'
        end
        @instance.attributes.delete('content_encoding')

        @instance.content_encoding = 'foo'
        @instance.save
        it "#content_encoding= should update content_encoding" do
          @instance.content_encoding = 'bar'
          @instance.save
          @instance.content_encoding.must_equal 'bar'
        end

        it "#content_encoding= should not blow up on nil" do
          @instance.content_encoding = nil
          @instance.save
        end
      end
    end
  end
end
