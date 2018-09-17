require "test_helper"

describe "Fog::OpenStack::Compute | keypair requests" do
  before do
    @keypair_format = {
      "public_key"  => String,
      "private_key" => String,
      "user_id"     => String,
      "name"        => String,
      "fingerprint" => String
    }

    @keypair_list_format = {
      "public_key"  => String,
      "name"        => String,
      "fingerprint" => String
    }
  end

  describe "success" do
    it "#create_key_pair((key_name, public_key = nil))" do
      Fog::OpenStack::Compute.new.create_key_pair('from_shindo_test').body.
        must_match_schema("keypair" => @keypair_format)
    end

    it "#list_key_pairs" do
      Fog::OpenStack::Compute.new.list_key_pairs.body.
        must_match_schema("keypairs" => [{"keypair" => @keypair_list_format}])
    end

    it "#delete_key_pair(key_name)" do
      Fog::OpenStack::Compute.new.delete_key_pair('from_shindo_test').status.must_equal 202
    end
  end
end
