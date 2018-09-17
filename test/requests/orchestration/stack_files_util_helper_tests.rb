require "test_helper"
require "yaml"
require "open-uri"

describe "Fog::OpenStack::Orchestration | stack requests" do
  @create_format_files = {
    'id'    => String,
    'links' => Array,
    'files' => Hash
  }
  before do
    @oldcwd = Dir.pwd
    Dir.chdir("test/requests/orchestration")
    @base_url = "file://" + File.absolute_path(".")
    @data = YAML.load_file("stack_files_util_tests.yaml")
    @template_yaml = YAML.load_file("template.yaml")
    @local_yaml = YAML.load_file("local.yaml")
    @orchestration = Fog::OpenStack::Orchestration.new
    @file_resolver = Fog::OpenStack::OrchestrationUtil::RecursiveHotFileLoader.new({})
  end
  after do
    Dir.chdir(@oldcwd)
  end

  describe "success" do
    it "#template_file_is_file" do
      assert(@file_resolver.send(:template_is_raw?, YAML.dump(@template_yaml)), true)
      assert(@file_resolver.send(:template_is_url?, "local.yaml"))
      refute(@file_resolver.send(:template_is_url?, YAML.dump(@template_yaml)))
      refute(@file_resolver.send(:template_is_url?, @template_yaml))
    end

    it "#read_uri_local" do
      content = @file_resolver.send(:read_uri, "template.yaml")
      assert_includes(content, "heat_template_version")
    end

    it "#read_uri_remote" do
      unless Fog.mocking?
        content = @file_resolver.send(:read_uri, "https://www.google.com/robots.txt")
        assert_includes(content, "Disallow:")
      end
    end

    it "#read_uri_404" do
      unless Fog.mocking?
        assert_raises OpenURI::HTTPError do
          @file_resolver.send(:read_uri, "https://www.google.com/NOOP")
        end
      end
    end

    it "#read_uri_bad_uri" do
      test_cases = %w[
        |no_command_execution
        |neither;\nhttp://localhost
        http:/../../../../../etc/passwd
      ]
      test_cases.each do |uri|
        assert_raises ArgumentError do
          @file_resolver.send(:read_uri, uri)
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
        assert_equal(@file_resolver.send(:base_url_for_url, data).to_s, expected)
      end
    end
  end
end
