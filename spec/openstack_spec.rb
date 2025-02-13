require 'spec_helper'

describe Fog::OpenStack do
  describe ".escape" do
    describe "when string includes dash" do
      it "does not escape dashes" do
        str = "this-is-hypenated"
        assert_equal str, Fog::OpenStack.escape(str)
      end
    end

    describe "when string includes dash and extra characters" do
      it "does not escape dashes" do
        str = "this-is-hypenated/"
        assert_equal str, Fog::OpenStack.escape(str, "/")
      end
    end

    describe "when string includes dash without extra characters" do
      it "does not escape dashes" do
        str = "this-is-hypenated/"
        expected = "this-is-hypenated%2F"
        assert_equal expected, Fog::OpenStack.escape(str)
      end
    end
  end
end