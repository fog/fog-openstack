require "test_helper"

describe "Fog::OpenStack::Image | image" do
  describe "success" do
    before do
      @instance = Fog::OpenStack::Image.new.images.create(:name => 'test image')
    end

    it "#create" do
      _(@instance.id.nil?).wont_be_nil
    end

    it "#update" do
      @instance.name = 'edit test image'
      @instance.update
      _(@instance.name).must_equal 'edit test image'
    end

    it "#get image metadata" do
      _(@instance.metadata["X-Image-Meta-Status"]).must_equal "active"
    end

    it "#add member" do
      _([200, 204]).must_include(@instance.add_member(@instance.owner).status)
    end

    it "#show members" do
      _(@instance.members[0]["member_id"]).wont_be_empty
    end

    it "#remove member" do
      _([200, 204]).must_include(@instance.remove_member(@instance.owner).status)
    end

    it "#destroy" do
      _(@instance.destroy).must_equal true
    end
  end
end
