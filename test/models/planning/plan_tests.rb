require "test_helper"

describe "Fog::OpenStack::Planning | plan" do
  describe "success" do
    before do
      @planning = Fog::OpenStack::Planning.new
      @instance = @planning.plans.first
      @role = @planning.list_roles.body.first
    end

    it "#add_role" do
      _(@instance.add_role(@role['uuid']).body["roles"][0]["uuid"]).must_equal @role['uuid']
    end

    it "#templates" do
      _(@instance.templates).wont_be_empty
    end

    it "#master_template" do
      _(@instance.master_template).must_be_kind_of String
    end

    it "#environment" do
      _(@instance.environment).must_be_kind_of String
    end

    it "#provider_resource_templates" do
      _(@instance.provider_resource_templates["provider-compute-1.yaml"]).wont_be_empty
    end

    it "#patch" do
      parameter = @instance.parameters.first
      _(@instance.patch(
        :parameters => [
          {
            "name"  => parameter['name'],
            "value" => 'new_value'
          }
        ]
      )["uuid"]).must_be_kind_of String
    end

    it "#remove_role" do
      _(@instance.remove_role(@role['uuid']).status).must_equal 200
    end

    it "#save" do
      _(@instance.save).must_be_kind_of Fog::OpenStack::Planning::Plan
    end

    it "#update" do
      _(@instance.update.uuid).wont_be_empty
    end

    it "#destroy" do
      _(@instance.destroy).must_equal true
    end

    it "#create" do
      _(@instance.create).must_be_kind_of Fog::OpenStack::Planning::Plan
    end
  end
end
