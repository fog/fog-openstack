require "test_helper"

describe "Fog::OpenStack::Image | image" do
  describe "success" do
    before do
      @instance = Fog::OpenStack::Image.new.images.create(:name => 'test image')
    end

    it "#create" do
      @instance.id.nil?.wont_be_nil
    end

    it "#update" do
      @instance.name = 'edit test image'
      @instance.update
      @instance.name.must_equal 'edit test image'
    end

    it "#get image metadata" do
      @instance.metadata["X-Image-Meta-Status"].must_equal "active"
    end

    it "#add member" do
      [200, 204].must_include(@instance.add_member(@instance.owner).status)
    end

    it "#show members" do
      @instance.members[0]["member_id"].wont_be_empty
    end

    it "#remove member" do
      [200, 204].must_include(@instance.remove_member(@instance.owner).status)
    end

    it "#destroy" do
      @instance.destroy.must_equal true
    end
  end
end
