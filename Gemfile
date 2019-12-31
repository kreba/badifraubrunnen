source 'https://rubygems.org'
ruby File.read(__dir__ + '/.tool-versions').match(/^ruby ([0-9.]+)/)[1] rescue puts "Gemfile failed to set ruby version"

# Not the newest, but Heroku uses only very specific versions of bundler.
# See https://devcenter.heroku.com/articles/bundler-version
# NB: Use specific versions of bundler like this: bundle _1.15.2_ update
gem 'bundler', '2.0.2'

gem 'rails', '~> 5.2.0'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# A more robust alternative to the Webrick webserver
gem 'puma'

# To start the application with the Procfile (which uses thin), used by heroku if present
# For more info on how to deploy on heroku, see https://devcenter.heroku.com/articles/rails3
#gem 'foreman' # not required atm, heroku's default behaviour 'rails server' is good enough (we don't have multiple worker processes anyway)

# To use a Postgresql database (See README for system requirements)
gem 'pg', '~> 1.0'

# Dalli: To use memcached-based fragment caching
# System requirements: memcached
# On Mac, try: brew install memcached
gem 'rails-observers'
gem 'memcachier'
gem 'dalli'

# Replaces ActiveSupport::Memoization
gem 'memoist'

# To generate PDF files from HTML
# Requires the executable 'wkhtmltopdf' to be available
gem 'pdfkit'

# For role based authorization à la current_person.is_admin_for? Saison.badi
gem 'authorization'

# For email validation (inkl live check whether the domain exists)
gem 'email_veracity'

# Form helper plug-in by Ryan Bates (eg, offers a simple 'add element' link for nested forms)
gem 'nested_form', '~> 0.3.2', :git => 'https://github.com/ryanb/nested_form.git'

gem 'sass-rails'
gem 'coffee-rails'

# See https://github.com/sstephenson/execjs#readme for more sed runtimes
# gem 'therubyracer'

gem 'uglifier'

gem 'jquery-rails'

gem 'test-unit'

group :production do
  gem 'rails_12factor'
end

group :development, :test do
  gem 'spring' # Faster testing thanks to pre-loading of (big chunks of) the environment. (Alternatives: spork, zeus, commands)
end

group :development do
  gem 'listen' # For auto-reloading upon file changes
  gem 'web-console'
end

group :test do
  gem 'factory_girl_rails'

  gem 'cucumber-rails', :require => false

  gem 'minitest-spec-rails'
  gem 'capybara_minitest_spec' # for capybara integration and spec matchers
  gem 'capybara-webkit'        # for headless javascript tests; see http://stackoverflow.com/questions/11354656/error-error-error-installing-capybara-webkit

  # TODO: make sure the database cleaner is working as expected (railscast shows some manual setup)
  gem 'database_cleaner' # as recommended by capybara & cucumber-rails;

  gem 'launchy' # For save_and_open_page

  # gem 'guard-minitest', :git => 'https://github.com/guard/guard-minitest' # Guard: On Mac OS X, make sure the rb-fsevent gem is installed so Guard can detect file changes.
  # gem 'guard-cucumber'

  gem 'turn' # for fancy test outputs
end
