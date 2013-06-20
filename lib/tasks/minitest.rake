require "rake/testtask"

Rake::TestTask.new(:test => "db:test:prepare") do |t|
  
  # TODO: Why u no work?!
  
  t.libs << "spec"
  t.pattern = "spec/**/*_spec.rb"
end

task :default => :test