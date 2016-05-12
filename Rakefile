require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'rake/testtask'

RuboCop::RakeTask.new

task :default => :test

desc 'Run fog-openstack unit tests'
task :test do
  mock = ENV['FOG_MOCK'] || 'true'
  sh("export FOG_MOCK=#{mock} && bundle exec shindont")
end

# The following is transition period until all shindo tests in /tests have been
# migrated over minitest /test
desc "Run fog-openstack unit tests for /test"
Rake::TestTask.new do |t|
  t.name = 'minitest'
  t.libs.push [ "lib", "test" ]
  t.test_files = FileList['test/openstack/*.rb']
  t.verbose = true
end

desc "Run fog-openstack unit tests for /spec"
Rake::TestTask.new do |t|
  t.name = 'spec'
  t.libs.push [ "lib", "spec" ]
  t.pattern = 'spec/**/*_spec.rb'
  t.verbose = true
end
