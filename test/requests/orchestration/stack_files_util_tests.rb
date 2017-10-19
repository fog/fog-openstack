require "test_helper"
require "yaml"
require "open-uri"
require "fog/orchestration/util/recursive_hot_file_loader"

describe "Fog::Orchestration[:openstack] | stack requests" do
  @create_format_files = {
    'id'    => String,
    'links' => Array,
    'files' => Hash
  }
  before do
    @oldcwd = Dir.pwd
    Dir.chdir("test/requests/orchestration")
    @orchestration = Fog::Orchestration[:openstack]
    @file_resolver = Fog::Orchestration::Util::RecursiveHotFileLoader.new(@template_yaml)
    @base_url = "file://" + File.absolute_path(".")
    @data = @file_resolver.yaml_load(open("stack_files_util_tests.yaml"))
    @template_yaml = @file_resolver.yaml_load(open("template.yaml"))
    @local_yaml = @file_resolver.yaml_load(open("local.yaml"))
  end
  after do
    Dir.chdir(@oldcwd)
  end

  describe "success" do
    it "#get_file_contents_simple" do
      test_cases = [
        ["a string", {}],
        [["a", "list"], {}],
        [{"a" => "dict", "b" => "values"}, {}],
        [{"type"=>"OS::Nova::Server"}, {}],
        [{"get_file" => "foo.sh", "b" => "values"}, {'foo.sh'=>'# Just a mock'}],
      ]
      test_cases.each do |data, expected|
        file_resolver = Fog::Orchestration::Util::RecursiveHotFileLoader.new(@template_yaml)
        file_resolver.get_file_contents(data)
        assert_equal(file_resolver.files, expected)
      end
    end

    it "#get_file_contents_local_template" do
      # Heat files parameter is populated with URI-like syntax. The expected
      #  values are absolute paths uri and should be resolved with the local
      #  directory.
      test_cases = @data['get_file_contents_local_template'].map do |testcase|
        [ testcase['input'], testcase['expected'] ]
      end.compact
      test_cases.each do |data, expected|
        Fog::Logger.warning("Testing with #{data} #{expected}")
        expected = prefix_with_url(expected, @base_url)
        file_resolver = Fog::Orchestration::Util::RecursiveHotFileLoader.new(@template_yaml)
        file_resolver.get_file_contents(data, @base_url)
        assert_equal(file_resolver.files.keys, expected)
      end
    end

    it "#get_file_contents_http_template" do
      skip if Fog.mocking?
      test_cases = @data["get_file_contents_http_template"].map do |testcase|
        [testcase['input'], testcase['expected']]
      end.compact
      test_cases.each do |data, expected|
        file_resolver = Fog::Orchestration::Util::RecursiveHotFileLoader.new(data)
        file_resolver.get_files
        assert_equal_set(file_resolver.files.keys, expected)
      end
    end

    it "#recurse_template_and_file" do
      test_cases = @data["get_file_contents_local_template"].map do |testcase|
        [testcase['input'], testcase['expected']]
      end.compact
      test_cases.push([@local_yaml, ["local.yaml", "hot_1.yaml"]])
      test_cases.each do |data, expected|
        expected = prefix_with_url(expected, @base_url)
        file_resolver = Fog::Orchestration::Util::RecursiveHotFileLoader.new(data)
        files = file_resolver.get_files
        assert_equal_set(files.keys, expected)
      end
    end

    it "#dont_modify_passed_template" do
      file_resolver = Fog::Orchestration::Util::RecursiveHotFileLoader.new(@local_yaml)
      file_resolver.get_files
      template = file_resolver.template

      # The template argument should be modified.
      assert(template['resources']['a_file']['type'].start_with?('file:///'), file_resolver.template)

      # No side effect on the original template.
      refute(@local_yaml['resources']['a_file']['type'].start_with?('file:///'))
    end
  end
end
