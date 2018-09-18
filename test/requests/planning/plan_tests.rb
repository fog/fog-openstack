require "test_helper"

describe "Fog::OpenStack::Planning | Planning plan requests" do
  before do
    @plan_format = {
      "created_at"  => Fog::Nullable::String,
      "description" => Fog::Nullable::String,
      "name"        => String,
      "parameters"  => Fog::Nullable::Array,
      "roles"       => Fog::Nullable::Array,
      "updated_at"  => Fog::Nullable::String,
      "uuid"        => String,
      "version"     => Fog::Nullable::Integer
    }

    @plan_templates_format = Hash
    @plans = Fog::OpenStack::Planning.new.list_plans.body
    @instance = @plans.first
    @role_instance = Fog::OpenStack::Planning.new.list_roles.body.first
  end

  describe "success" do
    it "#list_plans" do
      @plans.must_match_schema([@plan_format])
    end

    it "#get_plan" do
      Fog::OpenStack::Planning.new.get_plan(@instance['uuid']).body.must_match_schema(@plan_format)
    end

    it "#delete_plan" do
      Fog::OpenStack::Planning.new.delete_plan(@instance['uuid']).status.must_equal 204
    end

    it "#create_plan" do
      plan_attributes = {
        :name        => 'test-plan-name',
        :description => 'test-plan-desc',
      }
      @instance = Fog::OpenStack::Planning.new.create_plan(plan_attributes).body
      @instance.must_match_schema(@plan_format)
    end

    it "#add_role_to_plan" do
      Fog::OpenStack::Planning.new.add_role_to_plan(
        @instance['uuid'],
        @role_instance['uuid']
      ).body.must_match_schema(@plan_format)
    end

    it "#patch_plan" do
      parameters = Fog::OpenStack::Planning.new.get_plan(@instance['uuid']).
                   body['parameters'][0..1]
      plan_parameters = parameters.collect do |parameter|
        {
          "name"  => parameter['name'],
          "value" => "test-#{parameter['name']}-value",
        }
      end
      Fog::OpenStack::Planning.new.patch_plan(@instance['uuid'], plan_parameters).body.
        must_match_schema(@plan_format)
    end

    it "#get_plan_templates" do
      Fog::OpenStack::Planning.new.get_plan_templates(@instance['uuid']).body.
        must_match_schema(@plan_templates_format)
    end

    it "#remove_role_from_plan" do
      Fog::OpenStack::Planning.new.remove_role_from_plan(
        @instance['uuid'], @role_instance['uuid']
      ).body.must_match_schema(@plan_format)
    end
  end
end
