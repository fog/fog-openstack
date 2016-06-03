def collection_tests(collection, params = {})
  describe "success" do
    before do
      @instance = collection.create(params)

      unless Fog.mocking?
        @identity = @instance.identity
      end
    end

    it "#new(#{params.inspect})" do
      skip if Fog.mocking?
      collection.new(params).must_equal 200
    end

    it "#create(#{params.inspect})" do
      skip if Fog.mocking?
      @instance.must_be_kind_of Fog::Network::OpenStack::SecurityGroup
    end
    # FIXME: work around for timing issue on AWS describe_instances mocks

    if Fog.mocking? && @instance.respond_to?(:ready?)
      @instance.wait_for { ready? }
    end

    it "#all" do
      skip if Fog.mocking?
      collection.all.must_be_kind_of Fog::Network::OpenStack::SecurityGroups
    end

    it "#get(#{@identity})" do
      skip if Fog.mocking?
      collection.get(@identity).must_be_kind_of Fog::Network::OpenStack::SecurityGroup
    end

    unless Fog.mocking?
      describe "Enumerable" do
        before do
          methods = [
            'all?', 'any?', 'find', 'detect', 'collect', 'map',
            'find_index', 'flat_map', 'collect_concat', 'group_by',
            'none?', 'one?'
          ]

          # JRuby 1.7.5+ issue causes a SystemStackError: stack level too deep
          # https://github.com/jruby/jruby/issues/1265
          if RUBY_PLATFORM == "java" && JRUBY_VERSION =~ /1\.7\.[5-8]/
            methods.delete('all?')
          end
        end

        methods.each do |enum_method|
          if collection.respond_to?(enum_method)
            it "##{enum_method}" do
              block_called = false
              collection.send(enum_method) { block_called = true }
              block_called.must_equal true
            end
          end
        end

        %w{max_by, min_by}.each do |enum_method|
          if collection.respond_to?(enum_method)
            it "##{enum_method}" do
              block_called = false
              collection.send(enum_method) do
                block_called = true
                return 0
              end
              block_called.must_equal true
            end
          end
        end

        after do
          if block_given?
            yield(@instance)
          end

          if !Fog.mocking? || mocks_implemented
            @instance.destroy
          end
        end
      end
    end
  end

  describe "fails" do
    before do
      unless Fog.mocking?
        @identity = @identity.to_s
        @identity = @identity.gsub(/[a-zA-Z]/) { Fog::Mock.random_letters(1) }
        @identity = @identity.gsub(/\d/)       { Fog::Mock.random_numbers(1) }
        @identity
      end
    end

    it "#get(@identity" do
      skip if Fog.mocking?
      collection.get(@identity).must_equal nil
    end
  end
end
