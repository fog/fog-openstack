require "test_helper"

describe "Fog::OpenStack::Storage | large object requests" do
  before do
    @storage = Fog::OpenStack::Storage.new

    unless Fog.mocking?
      @directory  = @storage.directories.create(:key => 'foglargeobjecttests')
      @directory2 = @storage.directories.create(:key => 'foglargeobjecttests2')
      @segments = {
        :a => {
          :container => @directory.identity,
          :name      => 'fog_large_object/a',
          :data      => 'a' * (1024**2 + 10),
          :size      => 1024**2 + 10,
          :etag      => 'c2e97007d59f0c19b850debdcb80cca5'
        },
        :b => {
          :container => @directory.identity,
          :name      => 'fog_large_object/b',
          :data      => 'b' * (1024**2 + 20),
          :size      => 1024**2 + 20,
          :etag      => 'd35f50622a1259daad75ff7d5512c7ef'
        },
        :c => {
          :container => @directory.identity,
          :name      => 'fog_large_object2/a',
          :data      => 'c' * (1024**2 + 30),
          :size      => 1024**2 + 30,
          :etag      => '901d3531a87d188041d4d5b43cb464c1'
        },
        :d => {
          :container => @directory2.identity,
          :name      => 'fog_large_object2/b',
          :data      => 'd' * (1024**2 + 40),
          :size      => 1024**2 + 40,
          :etag      => '350c0e00525198813920a157df185c8d'
        }
      }
    end
  end

  after do
    unless Fog.mocking?
      @directory.files.each(&:destroy)
      @directory.destroy
      @directory2.files.each(&:destroy)
      @directory2.destroy
    end
  end

  describe "success" do
    before do
      unless Fog.mocking?
        @segments.each_value do |segment|
          @storage.put_object(segment[:container], segment[:name], segment[:data])
        end
      end
    end

    describe "dynamic large object requests" do
      it "#put_object_manifest alias" do
        unless Fog.mocking?
          @storage.put_object_manifest(@directory.identity, 'fog_large_object')
        end
      end

      describe "using default X-Object-Manifest header" do
        it "#put_dynamic_obj_manifest" do
          unless Fog.mocking?
            @storage.put_dynamic_obj_manifest(@directory.identity, 'fog_large_object')
          end
        end

        describe "with large object" do
          before do
            unless Fog.mocking?
              @segments.each_value do |segment|
                @storage.put_object(segment[:container], segment[:name], segment[:data])
              end
              @storage.put_dynamic_obj_manifest(@directory.identity, 'fog_large_object')
            end
          end

          it "#get_object streams all segments matching the default prefix" do
            unless Fog.mocking?
              expected = @segments[:a][:data] + @segments[:b][:data] + @segments[:c][:data]
              @storage.get_object(@directory.identity, 'fog_large_object').body.must_equal expected
            end
          end

          # When the manifest object name is equal to the segment prefix,
          # OpenStack treats it as if it's the first segment.
          # So you must prepend the manifest object's Etag - Digest::MD5.hexdigest('')
          it "#head_object returns Etag that includes manifest object in calculation" do
            unless Fog.mocking?
              etags = [
                'd41d8cd98f00b204e9800998ecf8427e',
                @segments[:a][:etag],
                @segments[:b][:etag],
                @segments[:c][:etag]
              ]
              # returned in quotes "\"2577f38428e895c50de6ea78ccc7da2a"\"
              expected = %("#{Digest::MD5.hexdigest(etags.join)}")
              @storage.head_object(@directory.identity, 'fog_large_object').headers['Etag'].must_equal expected
            end
          end
        end
      end

      describe "specifying X-Object-Manifest segment prefix" do
        it "#put_dynamic_obj_manifest" do
          unless Fog.mocking?
            options = {'X-Object-Manifest' => "#{@directory.identity}/fog_large_object/"}
            @storage.put_dynamic_obj_manifest(@directory.identity, 'fog_large_object', options)
          end
        end
        describe "with large object" do
          before do
            unless Fog.mocking?
              options = {'X-Object-Manifest' => "#{@directory.identity}/fog_large_object/"}
              @storage.put_dynamic_obj_manifest(@directory.identity, 'fog_large_object', options)
            end
          end

          it "#get_object streams segments only matching the specified prefix" do
            unless Fog.mocking?
              expected = @segments[:a][:data] + @segments[:b][:data]
              resp = @storage.get_object(@directory.identity, 'fog_large_object')
              resp.body.must_equal expected
            end
          end

          it "#head_object returns Etag that does not include manifest object in calculation" do
            unless Fog.mocking?
              etags = [@segments[:a][:etag], @segments[:b][:etag]]
              # returned in quotes "\"0f035ed3cc38aa0ef46dda3478fad44d"\"
              expected = %("#{Digest::MD5.hexdigest(etags.join)}")
              @storage.head_object(@directory.identity, 'fog_large_object').headers['Etag'].must_equal expected
            end
          end
        end
      end

      describe "storing manifest in a different container than the segments" do
        before do
          unless Fog.mocking?
            options = {'X-Object-Manifest' => "#{@directory.identity}/fog_large_object/"}
            @storage.put_dynamic_obj_manifest(@directory2.identity, 'fog_large_object', options)
          end
        end
        it "#get_object" do
          unless Fog.mocking?
            expected = @segments[:a][:data] + @segments[:b][:data]
            @storage.get_object(@directory2.identity, 'fog_large_object').body.must_equal expected
          end
        end
      end
    end

    describe "static large object requests" do
      describe "single container" do
        before do
          unless Fog.mocking?
            segments = [
              {
                :path       => "#{@segments[:a][:container]}/#{@segments[:a][:name]}",
                :etag       => @segments[:a][:etag],
                :size_bytes => @segments[:a][:size]
              },
              {
                :path       => "#{@segments[:c][:container]}/#{@segments[:c][:name]}",
                :etag       => @segments[:c][:etag],
                :size_bytes => @segments[:c][:size]
              }
            ]
            @storage.put_static_obj_manifest(@directory.identity, 'fog_large_object', segments)
          end
        end

        it "#head_object" do
          unless Fog.mocking?
            etags = [@segments[:a][:etag], @segments[:c][:etag]]
            # "\"ad7e633a12e8a4915b45e6dd1d4b0b4b\""
            etag = %("#{Digest::MD5.hexdigest(etags.join)}")
            content_length = @segments[:a][:size] + @segments[:c][:size]
            response = @storage.head_object(@directory.identity, 'fog_large_object')

            response.headers['Etag'].must_equal etag
            response.headers['Content-Length'].to_i.must_equal content_length
            response.headers['X-Static-Large-Object'].must_equal 'True'
          end
        end

        it "#get_object" do
          unless Fog.mocking?
            expected = @segments[:a][:data] + @segments[:c][:data]
            resp = @storage.get_object(@directory.identity, 'fog_large_object')
            resp.body.must_equal expected
          end
        end

        describe "#delete_static_large_object" do
          it "deletes manifest and segments" do
            unless Fog.mocking?
              expected = {
                'Number Not Found' => 0,
                'Response Status'  => '200 OK',
                'Errors'           => [],
                'Number Deleted'   => 3,
                'Response Body'    => ''
              }
              @storage.delete_static_large_object(@directory.identity, 'fog_large_object').body.must_equal expected
            end
          end
        end
      end

      describe "multiple containers" do
        before do
          unless Fog.mocking?
            segments = [
              {
                :path       => "#{@segments[:b][:container]}/#{@segments[:b][:name]}",
                :etag       => @segments[:b][:etag],
                :size_bytes => @segments[:b][:size]
              },
              {
                :path       => "#{@segments[:d][:container]}/#{@segments[:d][:name]}",
                :etag       => @segments[:d][:etag],
                :size_bytes => @segments[:d][:size]
              }
            ]
            @storage.put_static_obj_manifest(@directory2.identity, 'fog_large_object', segments)
          end
        end

        it "#head_object" do
          unless Fog.mocking?
            etags = [@segments[:b][:etag], @segments[:d][:etag]]
            # "\"9801a4cc4472896a1e975d03f0d2c3f8\""
            etag = %("#{Digest::MD5.hexdigest(etags.join)}")
            content_length = (@segments[:b][:size] + @segments[:d][:size])
            response = @storage.head_object(@directory2.identity, 'fog_large_object')

            response.headers['Etag'].must_equal etag
            response.headers['Content-Length'].to_i.must_equal content_length
            response.headers['X-Static-Large-Object'].must_equal 'True'
          end
        end

        it "#get_object" do
          unless Fog.mocking?
            expected = @segments[:b][:data] + @segments[:d][:data]
            resp = @storage.get_object(@directory2.identity, 'fog_large_object')
            resp.body.must_equal expected
          end
        end

        it "#delete_static_large_object" do
          unless Fog.mocking?
            expected = {
              'Number Not Found' => 0,
              'Response Status'  => '200 OK',
              'Errors'           => [],
              'Number Deleted'   => 3,
              'Response Body'    => ''
            }
            resp = @storage.delete_static_large_object(@directory2.identity, 'fog_large_object')
            resp.body.must_equal expected
          end
        end
      end
    end
  end

  describe "failure" do
    describe "dynamic large object requests" do
      it "#put_dynamic_obj_manifest with missing container" do
        unless Fog.mocking?
          proc do
            @storage.put_dynamic_obj_manifest('fognoncontainer', 'fog_large_object')
          end.must_raise Fog::OpenStack::Storage::NotFound
        end
      end
    end

    describe "static large object requests" do
      it "#put_static_obj_manifest with missing container" do
        unless Fog.mocking?
          proc do
            @storage.put_static_obj_manifest('fognoncontainer', 'fog_large_object', [])
          end.must_raise Fog::OpenStack::Storage::NotFound
        end
      end

      it "#put_static_obj_manifest with missing object" do
        unless Fog.mocking?
          segments = [{
            :path       => "#{@segments[:c][:container]}/#{@segments[:c][:name]}",
            :etag       => @segments[:c][:etag],
            :size_bytes => @segments[:c][:size]
          }]
          expected = {'Errors' => [[segments[0][:path], '404 Not Found']]}

          err = proc do
            @storage.put_static_obj_manifest(@directory.identity, 'fog_large_object', segments)
          end.must_raise Excon::Errors::BadRequest
          Fog::JSON.decode(err.response.body).must_equal expected
        end
      end

      describe "with segments" do
        before do
          unless Fog.mocking?
            @segments.each_value do |segment|
              @storage.put_object(segment[:container], segment[:name], segment[:data])
            end
          end
        end

        it "#put_static_obj_manifest with invalid etag" do
          unless Fog.mocking?

            segments = [{
              :path       => "#{@segments[:a][:container]}/#{@segments[:a][:name]}",
              :etag       => @segments[:b][:etag],
              :size_bytes => @segments[:a][:size]
            }]
            expected = {'Errors' => [[segments[0][:path], 'Etag Mismatch']]}

            err = proc do
              @storage.put_static_obj_manifest(@directory.identity, 'fog_large_object', segments)
            end.must_raise Excon::Errors::BadRequest

            Fog::JSON.decode(err.response.body).must_equal expected
          end
        end

        it "#put_static_obj_manifest with invalid byte_size" do
          unless Fog.mocking?
            segments = [{
              :path       => "#{@segments[:a][:container]}/#{@segments[:a][:name]}",
              :etag       => @segments[:a][:etag],
              :size_bytes => @segments[:b][:size]
            }]
            expected = {'Errors' => [[segments[0][:path], 'Size Mismatch']]}

            err = proc do
              @storage.put_static_obj_manifest(@directory.identity, 'fog_large_object', segments)
            end.must_raise Excon::Errors::BadRequest

            Fog::JSON.decode(err.response.body).must_equal expected
          end
        end

        describe "#delete_static_large_object with missing segment" do
          before do
            unless Fog.mocking?
              segments = [
                {
                  :path       => "#{@segments[:a][:container]}/#{@segments[:a][:name]}",
                  :etag       => @segments[:a][:etag],
                  :size_bytes => @segments[:a][:size]
                },
                {
                  :path       => "#{@segments[:b][:container]}/#{@segments[:b][:name]}",
                  :etag       => @segments[:b][:etag],
                  :size_bytes => @segments[:b][:size]
                }
              ]
              @storage.put_static_obj_manifest(@directory.identity, 'fog_large_object', segments)
              @storage.delete_object(@segments[:b][:container], @segments[:b][:name])
            end
          end

          it "deletes manifest and segment :a, and reports missing segment :b" do
            unless Fog.mocking?
              expected = {
                'Number Not Found' => 1,
                'Response Status'  => '200 OK',
                'Errors'           => [],
                'Number Deleted'   => 2,
                'Response Body'    => ''
              }
              @storage.delete_static_large_object(@directory.identity, 'fog_large_object').body.must_equal expected
            end
          end
        end
      end

      it "#delete_static_large_object with missing container" do
        unless Fog.mocking?
          expected = {
            'Number Not Found' => 1,
            'Response Status'  => '200 OK',
            'Errors'           => [],
            'Number Deleted'   => 0,
            'Response Body'    => ''
          }

          resp = @storage.delete_static_large_object('fognoncontainer', 'fog_large_object')
          resp.body.must_equal expected
        end
      end

      it "#delete_static_large_object with missing manifest" do
        unless Fog.mocking?
          expected = {
            'Number Not Found' => 1,
            'Response Status'  => '200 OK',
            'Errors'           => [],
            'Number Deleted'   => 0,
            'Response Body'    => ''
          }

          @storage.delete_static_large_object(@directory.identity, 'fog_non_object').body.must_equal expected
        end
      end
    end
  end
end
