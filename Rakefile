require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'rake/testtask'

RuboCop::RakeTask.new

task :default => ['tests:unit', 'tests:spec']

task :test => 'tests:unit'

task :spec => "tests:spec"

namespace :tests do
  desc 'Run fog-openstack tests with Minitest'
  Rake::TestTask.new do |t|
    ENV['FOG_MOCK']= ENV['FOG_MOCK'].nil? ? 'true' : ENV['FOG_MOCK']

    t.name = 'unit'
    t.libs.push [ "lib", "test" ]
    t.test_files = FileList['test/**/*.rb']
    t.verbose = true
  end

  desc 'Run fog-openstack tests with RSpec and VCR'
  Rake::TestTask.new do |t|
    t.name = 'spec'
    t.libs.push [ "lib", "spec" ]
    t.pattern = 'spec/**/*_spec.rb'
    t.verbose = true
  end
end
