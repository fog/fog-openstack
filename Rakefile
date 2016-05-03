require 'bundler/gem_tasks'
require 'rubocop/rake_task'

RuboCop::RakeTask.new

task :default => :test

desc 'Run fog-openstack unit tests'
mock = ENV['FOG_MOCK'] || 'true'
task :test => [:vcr] do
  sh("export FOG_MOCK=#{mock} && bundle exec shindont")
end

task :vcr do
  sh("export FOG_MOCK=false && bundle exec rspec spec/fog/*_spec.rb")
  sh("export SPEC_PATH=spec/fog/network_api_path \
               OS_AUTH_URL=http://devstack.openstack.stack:5000/id/v3 \
               USE_VCR=true && bundle exec rspec spec/fog/network_spec.rb")
end
