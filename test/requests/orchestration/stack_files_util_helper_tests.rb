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
    it "#template_file_is_hot" do
      assert(@file_resolver.template_is_raw?(YAML.dump(@template_yaml)), true)
    end

    it "#template_file_is_file" do
      assert(@file_resolver.template_is_url?("local.yaml"))
      refute(@file_resolver.template_is_url?(YAML.dump(@template_yaml)))
      refute(@file_resolver.template_is_url?(@template_yaml))
    end

    it "#get_content_local" do
      content = @file_resolver.get_content("template.yaml")
      assert_includes(content, "heat_template_version")
    end

    it "#get_content_remote" do
      skip if Fog.mocking?
      content = @file_resolver.get_content("https://www.google.com/robots.txt")
      assert_includes(content, "Disallow:")
    end

    it "#get_content_404" do
      skip if Fog.mocking?
      assert_raises OpenURI::HTTPError do
        @file_resolver.get_content("https://www.google.com/NOOP")
      end
    end

    it "#get_content_bad_uri" do
      test_cases = %w[
        |no_command_execution
        |neither;\nhttp://localhost
        http:/../../../../../etc/passwd
      ]
      test_cases.each do |uri|
        assert_raises ArgumentError do
          @file_resolver.get_content(uri)
        end
      end
    end


    it "#base_url_for_url" do
      test_cases = [
        %w(file:///f.txt file:///),
        %w(file:///a/f.txt file:///a),
        %w(file:///a/b/f.txt file:///a/b),
        %w(http://h.com/a/f.txt http://h.com/a),
        %w(https://h.com/a/b/f.txt https://h.com/a/b),
      ]
      test_cases.each do |data, expected|
        assert_equal(@file_resolver.base_url_for_url(data).to_s, expected)
      end
    end
  end
end
