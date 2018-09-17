require "test_helper"

describe "Fog::OpenStack::Planning | Planning role requests" do
  before do
    @role_format = {
      'description' => Fog::Nullable::String,
      'name'        => Fog::Nullable::String,
      'uuid'        => String,
      'version'     => Integer,
    }
  end

  describe "success" do
    it "#list_roles" do
      Fog::OpenStack::Planning.new.list_roles.body.must_match_schema([@role_format])
    end
  end
end
