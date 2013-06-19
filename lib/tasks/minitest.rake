require "rake/testtask"

Rake::TestTask.new(:test => "db:test:prepare") do |t|
  t.libs << "test"
  t.pattern = "test/**/*_spec.rb"
end

task :default => :test