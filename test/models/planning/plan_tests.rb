require "test_helper"

describe "Fog::OpenStack::Planning | plan" do
  describe "success" do
    before do
      @planning = Fog::OpenStack::Planning.new
      @instance = @planning.plans.first
      @role = @planning.list_roles.body.first
    end

    it "#add_role" do
      @instance.add_role(@role['uuid']).body["roles"][0]["uuid"].must_equal @role['uuid']
    end

    it "#templates" do
      @instance.templates.wont_be_empty
    end

    it "#master_template" do
      @instance.master_template.must_be_kind_of String
    end

    it "#environment" do
      @instance.environment.must_be_kind_of String
    end

    it "#provider_resource_templates" do
      @instance.provider_resource_templates["provider-compute-1.yaml"].wont_be_empty
    end

    it "#patch" do
      parameter = @instance.parameters.first
      @instance.patch(
        :parameters => [
          {
            "name"  => parameter['name'],
            "value" => 'new_value'
          }
        ]
      )["uuid"].must_be_kind_of String
    end

    it "#remove_role" do
      @instance.remove_role(@role['uuid']).status.must_equal 200
    end

    it "#save" do
      @instance.save.must_be_kind_of Fog::OpenStack::Planning::Plan
    end

    it "#update" do
      @instance.update.uuid.wont_be_empty
    end

    it "#destroy" do
      @instance.destroy.must_equal true
    end

    it "#create" do
      @instance.create.must_be_kind_of Fog::OpenStack::Planning::Plan
    end
  end
end
