require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require "rdoc/task"

RSpec::Core::RakeTask.new('spec')

task :default => :spec

Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = 'Yet Another Way to Parse Arguments'
  rdoc.rdoc_files.include('lib/**/*.rb')
end
