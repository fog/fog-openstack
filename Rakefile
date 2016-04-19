require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require "minitest/spec"

RuboCop::RakeTask.new

task :default => :test

desc 'Run fog-openstack unit tests'
task :test do
  mock = ENV['FOG_MOCK'] || 'true'
  sh("export FOG_MOCK=#{mock} && bundle exec shindont")
end

require 'rake/testtask'

desc "Run fog-openstack unit tests for /spec"
Rake::TestTask.new do |t|
  t.name = 'spec'
  t.libs.push [ "lib", "spec" ]
  t.pattern = 'spec/**/*_spec.rb'
  t.verbose = true
end
