# To Do: Move this test to fog-core
require 'test_helper'

describe "Fog::Schema::DataValidator, 'meta'" do
  let(:validator) { Fog::Schema::DataValidator.new }

  describe "#validate" do
    it "returns true when value matches schema expectation" do
      validator.validate({"key" => "Value"}, "key" => String).must_equal true
    end

    it "returns true when values within an array all match schema expectation" do
      validator.validate({"key" => [1, 2]}, "key" => [Integer]).must_equal true
    end

    it "returns true when nested values match schema expectation" do
      validator.validate({"key" => {:nested_key => "Value"}}, "key" => {:nested_key => String}).must_equal true
    end

    it "returns true when collection of values all match schema expectation" do
      validator.validate([{"key" => "Value"}, {"key" => "Value"}], [{"key" => String}]).must_equal true
    end

    it "returns true when collection is empty although schema covers optional members" do
      validator.validate([], [{"key" => String}]).must_equal true
    end

    it "returns true when additional keys are passed and not strict" do
      validator.validate({"key" => "Value", :extra => "Bonus"}, {"key" => String}, :allow_extra_keys => true).must_equal true
    end

    it "returns true when value is nil and schema expects NilClass" do
      validator.validate({"key" => nil}, {"key" => NilClass}).must_equal true
    end

    it "returns true when value and schema match as hashes" do
      validator.validate({}, {}).must_equal true
    end

    it "returns true when value and schema match as arrays" do
      validator.validate([], []).must_equal true
    end

    it "returns true when value is a Time" do
      validator.validate({"time" => Time.now}, "time" => Time).must_equal true
    end

    it "returns true when key is missing but value should be NilClass (#1477)" do
      validator.validate({}, {"key" => NilClass}, :allow_optional_rules => true).must_equal true
    end

    it "returns true when key is missing but value is nullable (#1477)" do
      validator.validate({}, {"key" => Fog::Nullable::String}, :allow_optional_rules => true).must_equal true
    end

    it "returns false when value does not match schema expectation" do
      validator.validate({"key" => nil}, "key" => String).must_equal false
    end

    it "returns false when key formats do not match" do
      validator.validate({"key" => "Value"}, :key => String).must_equal false
    end

    it "returns false when additional keys are passed and strict" do
      validator.validate({"key" => "Missing"}, {}).must_equal false
    end

    it "returns false when some keys do not appear" do
      validator.validate({}, "key" => String).must_equal false
    end

    it "returns false when collection contains a member that does not match schema" do
      validator.validate([{"key" => "Value"}, {"key" => 5}], [{"key" => String}]).must_equal false
    end

    it "returns false when collection has multiple schema patterns" do
      validator.validate([{"key" => "Value"}], [{"key" => Integer}, {"key" => String}]).must_equal false
    end

    it "returns false when hash and array are compared" do
      validator.validate({}, []).must_equal false
    end

    it "returns false when array and hash are compared" do
      validator.validate([], {}).must_equal false
    end

    it "returns false when a hash is expected but another data type is found" do
      validator.validate({"key" => {:nested_key => []}}, "key" => {:nested_key => {}}).must_equal false
    end

    it "returns false when key is missing but value should be NilClass (#1477)" do
      validator.validate({}, {"key" => NilClass}, :allow_optional_rules => false).must_equal false
    end

    it "returns false when key is missing but value is nullable (#1477)" do
      validator.validate({}, {"key" => Fog::Nullable::String}, :allow_optional_rules => false).must_equal false
    end
  end
end
