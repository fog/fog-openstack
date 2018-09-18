require "test_helper"
describe "Fog::OpenStack::Image | images" do
  before do
    @instance = Fog::OpenStack::Image.new.create_image(:name => "model test image").body
  end

  describe "success" do
    it "#find_by_id" do
      image = Fog::OpenStack::Image.new.images.find_by_id(@instance['image']['id'])
      image.id.must_equal @instance['image']['id']
    end

    it "#get" do
      image = Fog::OpenStack::Image.new.images.get(@instance['image']['id'])
      image.id.must_equal @instance['image']['id']
    end

    it "#destroy" do
      Fog::OpenStack::Image.new.images.destroy(@instance['image']['id']).must_equal true
    end
  end
end
