require "test_helper"
require "helpers/network_helper"
require "helpers/collection_helper"

describe "Fog::OpenStack::Network | security_groups collection" do
  @attributes = {
    :name        => "my_secgroup",
    :description => "my sec group desc"
  }

  collection_tests(network.security_groups, @attributes)

  describe "success" do
    before do
      @attributes = {
        :name        => "fogsecgroup",
        :description => "fog sec group desc"
      }

      @secgroup = network.security_groups.create(@attributes)
    end

    after do
      @secgroup.destroy
    end

    it "#all(filter)" do
      secgroup = network.security_groups.all(:name => "fogsecgroup")
      secgroup.first.name.wont_be_empty
    end
  end
end
