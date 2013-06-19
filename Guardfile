# More info at https://github.com/guard/guard#readme

guard 'minitest' do
  # with Minitest::Spec
  watch(%r|^spec/(.*)_spec.rb$|)
  watch(%r|^lib/(.*)([^/]+).rb$|)       { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
  watch(%r|^spec/factories.rb$|)        { "spec" }
  watch(%r|^spec/.*_helper.rb$|)        { "spec" }

  # Rails 3.2
  watch(%r|^app/controllers/(.*).rb$|)  { |m| "test/controllers/#{m[1]}_test.rb" }
  watch(%r|^app/helpers/(.*).rb$|)      { |m| "test/helpers/#{m[1]}_test.rb" }
  watch(%r|^app/models/(.*).rb$|)       { |m| "test/models/#{m[1]}_test.rb" }
  watch(%r|^app/config/routes.rb$|)     { |m| "test/routing" }
end
