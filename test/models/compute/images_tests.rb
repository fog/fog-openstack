require "test_helper"

describe "Fog::OpenStack::Compute | images collection" do
  describe "success" do
    describe "#all" do
      let (:fog) { Fog::OpenStack::Compute.new }

      it "must be an Array" do
        _(fog.images.all).must_be_kind_of Array
      end

      it "wont be nil" do
        _(fog.images.all).wont_be_nil
      end
    end
  end
end
