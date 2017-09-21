require "test_helper"
require 'fog/core'

describe "Fog::Orchestration[:openstack] | stack requests" do
  before do
    @oldcwd = Dir.pwd
    Dir.chdir("test/requests/orchestration")
    @base_url = URI.join("file:", File.absolute_path("."))
    @base_url.host = ""

    @orchestration = Fog::Orchestration[:openstack]

    @stack_format = {
      'links'               => Array,
      'id'                  => String,
      'stack_name'          => String,
      'description'         => Fog::Nullable::String,
      'stack_status'        => String,
      'stack_status_reason' => String,
      'creation_time'       => Time,
      'updated_time'        => Time
    }

    @stack_detailed_format = {
      "parent"                => Fog::Nullable::String,
      "disable_rollback"      => Fog::Boolean,
      "description"           => String,
      "links"                 => Array,
      "stack_status_reason"   => String,
      "stack_name"            => String,
      "stack_user_project_id" => String,
      "stack_owner"           => String,
      "creation_time"         => Fog::Nullable::String,
      "capabilities"          => Array,
      "notification_topics"   => Array,
      "updated_time"          => Fog::Nullable::String,
      "timeout_mins"          => Fog::Nullable::String,
      "stack_status"          => String,
      "parameters"            => Hash,
      "id"                    => String,
      "outputs"               => Array,
      "template_description"  => String
    }

    @create_format = {
      'id'    => String,
      'links' => Array,
    }

    @create_format_files = {
      'id'    => String,
      'links' => Array,
      'files' => Hash
    }
  end
  after do
    Dir.chdir(@oldcwd)
  end

  describe "success" do
    it "#create_stack" do
      @stack = @orchestration.create_stack("teststack").body.must_match_schema(@create_format)
    end

    it "#create_stack_with_files" do
      args = {
        :stack_name => "teststack_files",
        :files      => {'foo.sh'=>'hello'}
      }
      @stack = @orchestration.create_stack(args).body.must_match_schema(@create_format_files)
    end

    it "#create_stack_resolve_files" do
      expected = prefix_with_url(["local.yaml", "hot_1.yaml"], @base_url.to_s)
      args = {
        :stack_name => "teststack_files",
        :template   => YAML.safe_load(open("local.yaml")),
      }
      response = @orchestration.create_stack(args)
      response.body.must_match_schema(@create_format_files)
      files = response.body['files']
      Fog::Logger.warning("Request processed: #{files.keys}")
      assert_equal_set(expected, files.keys)
    end

    it "#list_stack_data" do
      @orchestration.list_stack_data.body.must_match_schema('stacks' => [@stack_format])
    end

    it "#list_stack_data_Detailed" do
      @orchestration.list_stack_data_detailed.body.must_match_schema('stacks' => [@stack_detailed_format])
    end

    it "#update_stack" do
      @orchestration.update_stack("teststack").body.must_match_schema({})
    end

    it "#patch_stack" do
      @orchestration.patch_stack(@stack).body.must_match_schema({})
    end

    it "#delete_stack" do
      @orchestration.delete_stack("teststack", "id").body.must_match_schema({})
    end

    it "#cancel_update" do
      @orchestration.cancel_update(@stack).body.must_match_schema({})
    end
  end
end
