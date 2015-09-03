task :release => :spec # BEFORE bundler gem tasks.

require "bundler/gem_tasks"

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec)

require "yard"
YARD::Rake::YardocTask.new(:doc)

task :default => :spec
