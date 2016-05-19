require 'rspec/core/rake_task'

task :default => :spec

desc 'Task to run unit tests'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
end