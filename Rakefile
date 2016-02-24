require 'bundler/gem_tasks'
require 'rubocop/rake_task'

RuboCop::RakeTask.new

task :default => :test

desc 'Run fog-openstack unit tests'
mock = ENV['FOG_MOCK'] || 'true'
task :test do
  sh("export FOG_MOCK=#{mock} && bundle exec shindont")
end
