def model_tests(collection, params = {})
  describe "success" do
    before do
      @instance = collection.new(params)

      if block_given?
        yield(@instance)
      end
    end

    it "#save" do
      unless Fog.mocking?
        @instance.save.must_equal true
      end
    end

    it "#destroy" do
      unless Fog.mocking?
        @instance.destroy.must_equal 200
      end
    end
  end
end

# Generates a unique identifier with a random differentiator.
# Useful when rapidly re-running tests, so we don't have to wait
# serveral minutes for deleted objects to disappear from the API
# E.g. 'fog-test-1234'
def uniq_id(base_name = 'fog-test')
  # random_differentiator
  suffix = rand(65536).to_s(16).rjust(4, '0')
  [base_name, suffix].join '-'
end
