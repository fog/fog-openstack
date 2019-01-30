require "test_helper"
require 'fog/openstack/workflow'
require 'fog/openstack/workflow/v2'

describe "Fog::OpenStack::Workflow | Workflow requests" do
  before do
    @workflow = Fog::OpenStack::Workflow.new
    @execution_id = Fog::UUID.uuid

    @workflow_name = "tripleo.plan_management.v1.create_default_deployment_plan"
    @input = { :container => 'default' }

    @get_execution_response = {
      "state" => "running",
      "id"    => "1111"
    }

    @workbook_sample = {
      "version"     => "2.0",
      "name"        => "workbook1",
      "description" => "d1",
    }

    @workflow_sample = {
      "version"     => "2.0",
      "name"        => "workflow1",
      "description" => "d1",
    }

    @action_sample = {
      "version" => "2.0",
      "action1" => {
        "input" => ['test_id']
      }
    }

    @task_sample = {
      "version" => "2.0",
      "task1" => {
        "id" => ['test_id']
      }
    }

    @cron_trigger_sample = {
      "version"     => "2.0",
      "name"        => "cron_trigger1",
      "description" => "d1",
    }

    @environment_sample = {
      "name" => "environment1",
      "variables" => {
        "var1" => "value1",
        "var2" => "value2"
      }
    }
  end

  describe "success" do
    it "#create_execution" do
      @workflow.create_execution(@workflow_name, @input).status.must_equal 201
    end

    it "#get_execution" do
      response = @workflow.get_execution(@execution_id)
      response.status.must_equal 200
      response.body.must_match_schema(@get_execution_response)
    end

    it "#list_executions" do
      @workflow.list_executions.status.must_equal 200
    end

    it "#update_execution" do
      response = @workflow.update_execution(@execution_id, "description", "changed description")
      response.status.must_equal 200
    end

    it "#delete_execution" do
      response = @workflow.delete_execution(@execution_id)
      response.status.must_equal 204
    end

    it "#create_action_execution" do
      action_name = "tripleo.list_roles"
      @workflow.create_action_execution(action_name, @input).status.must_equal 201
    end

    it "#get_action_execution" do
      response = @workflow.get_action_execution(@execution_id)
      response.status.must_equal 200
      response.body.must_match_schema(@get_execution_response)
    end

    it "#list_action_executions" do
      @workflow.list_action_executions.status.must_equal 200
    end

    it "#update_action_execution" do
      response = @workflow.update_action_execution(@execution_id, "output", "changed output")
      response.status.must_equal 200
    end

    it "#delete_action_execution" do
      response = @workflow.delete_action_execution(@execution_id)
      response.status.must_equal 204
    end

    it "#create_workbook" do
      @workflow.create_workbook(@workbook_sample).status.must_equal 201
    end

    it "#get_workbook" do
      response = @workflow.get_workbook(@workbook_sample[:name])
      response.status.must_equal 200
      response.body.must_match_schema(@workbook_sample)
    end

    it "#list_workbooks" do
      @workflow.list_workbooks.status.must_equal 200
    end

    it "#update_workbook" do
      response = @workflow.update_workbook(@workbook_sample)
      response.status.must_equal 200
    end

    it "#validate_workbook" do
      response = @workflow.validate_workbook(@workbook_sample)
      response.status.must_equal 200
    end

    it "#delete_workbook" do
      response = @workflow.delete_workbook(@workbook_sample[:name])
      response.status.must_equal 204
    end

    it "#create_workflow" do
      @workflow.create_workflow(@workflow_sample).status.must_equal 201
    end

    it "#get_workflow" do
      response = @workflow.get_workflow(@workflow_sample[:name])
      response.status.must_equal 200
      response.body.must_match_schema(@workflow_sample)
    end

    it "#list_workflows" do
      @workflow.list_workflows.status.must_equal 200
    end

    it "#update_workflow" do
      response = @workflow.update_workflow(@workflow_sample)
      response.status.must_equal 200
    end

    it "#validate_workflow" do
      response = @workflow.validate_workflow(@workflow_sample)
      response.status.must_equal 200
    end

    it "#delete_workflow" do
      response = @workflow.delete_workflow(@workflow_sample[:name])
      response.status.must_equal 204
    end

    it "#create_action" do
      @workflow.create_action(@action_sample).status.must_equal 201
    end

    it "#get_action" do
      response = @workflow.get_action("action1")
      response.status.must_equal 200
      response.body.must_match_schema(@action_sample)
    end

    it "#list_actions" do
      @workflow.list_actions.status.must_equal 200
    end

    it "#update_action" do
      response = @workflow.update_action(@action_sample)
      response.status.must_equal 200
    end

    it "#validate_action" do
      response = @workflow.validate_action(@action_sample)
      response.status.must_equal 200
    end

    it "#delete_action" do
      response = @workflow.delete_action("action1")
      response.status.must_equal 204
    end

    it "#get_task" do
      response = @workflow.get_task("1")
      response.status.must_equal 200
      response.body.must_match_schema(@task_sample)
    end

    it "#list_tasks" do
      response = @workflow.validate_action("1")
      response.status.must_equal 200
    end

    it "#rerun_task" do
      response = @workflow.delete_action("1")
      response.status.must_equal 204
    end

    it "#create_cron_trigger" do
      @workflow.create_cron_trigger("cron1", 1, "input").status.must_equal 201
    end

    it "#get_cron_trigger" do
      response = @workflow.get_cron_trigger("cron1")
      response.status.must_equal 200
      response.body.must_match_schema(@cron_trigger_sample)
    end

    it "#list_cron_triggers" do
      @workflow.list_cron_triggers.status.must_equal 200
    end

    it "#delete_cron_trigger" do
      response = @workflow.delete_cron_trigger("cron1")
      response.status.must_equal 204
    end

    it "#create_environment" do
      @workflow.create_environment(@environment_sample).status.must_equal 201
    end

    it "#get_environment" do
      response = @workflow.get_environment("environment1")
      response.status.must_equal 200
      response.body.must_match_schema(@environment_sample)
    end

    it "#list_environments" do
      @workflow.list_environments.status.must_equal 200
    end

    it "#update_environment" do
      response = @workflow.update_environment(@environment_sample)
      response.status.must_equal 200
    end

    it "#delete_environment" do
      response = @workflow.delete_environment("environment1")
      response.status.must_equal 204
    end
  end
end
