# More info at https://github.com/guard/guard#readme

# THIS IS NO USE since guard is invoked on the shell as a precompiled binary. Makes sense, pity though...
# require File.dirname(__FILE__) + '/config/spring_testspec_in_guard'
# guard 'minitest', :spring => 'testspec' do ...

guard 'minitest' do
  # with Minitest::Spec
  watch(%r|^spec/(.*)_spec.rb$|)
  watch(%r|^lib/(.*).rb$|)        { |m| "spec/#{m[1]}.rb" }
  watch(%r|^spec/factories.rb$|)  { "spec" }
  watch(%r|^spec/.*_helper.rb$|)  { "spec" }
  watch(%r|^spec/support|)        { "spec" }

  # Rails 3.2
  watch(%r|^app/controllers/(.*).rb$|)  { |m| "spec/controllers/#{m[1]}_test.rb" }
  watch(%r|^app/helpers/(.*).rb$|)      { |m| "spec/helpers/#{m[1]}_test.rb" }
  watch(%r|^app/models/(.*).rb$|)       { |m| "spec/models/#{m[1]}_test.rb" }
  watch(%r|^app/config/routes.rb$|)     { |m| "spec/routing" }
end

# guard 'minitest', :spring => true do
#   # with Minitest::Unit
#   watch(%r|^test/(.*)\/?test_(.*)\.rb|)
#   watch(%r|^lib/(.*)([^/]+)\.rb|)       { |m| "test/#{m[1]}test_#{m[2]}.rb" }
#   watch(%r|^test/test_helper\.rb|)      { "test" }
# 
#   # Rails 3.2
#   watch(%r|^app/controllers/(.*)\.rb|)  { |m| "test/controllers/#{m[1]}_test.rb" }
#   watch(%r|^app/helpers/(.*)\.rb|)      { |m| "test/helpers/#{m[1]}_test.rb" }
#   watch(%r|^app/models/(.*)\.rb|)       { |m| "test/unit/#{m[1]}_test.rb" }  
# end

guard 'cucumber' do
  watch(%r{^features/.+.feature$})
  watch(%r{^features/support/.+$})                     { 'features' }
  watch(%r{^features/step_definitions/(.+)_steps.rb$}) { |m| Dir[File.join("**/#{m[1]}.feature")][0] || 'features' }
end
