require 'test_helper'

describe "Fog::OpenStack::Network | extension requests" do
  before do
    @extension_format = {
      'id'          => String,
      'alias'       => String,
      'description' => String,
      'links'       => Array,
      'name'        => String
    }
  end

  describe "success" do
    it "#list_extensions" do
      network.list_extensions.body.
        must_match_schema('extensions' => [@extension_format])
    end

    it "#get_extension" do
      extension_id = network.extensions.all.first.id
      network.get_extension(extension_id).body.
        must_match_schema('extension' => @extension_format)
    end
  end

  describe "failure" do
    it "#get_extension" do
      proc do
        network.get_extension(0)
      end.must_raise Fog::OpenStack::Network::NotFound
    end
  end
end
