source 'https://rubygems.org'
ruby '1.9.3' #keep in sync with .ruby-version

gem 'rails', '3.2.13'

# Form helper plug-in by Ryan Bates (eg, offers a simple 'add element' link for nested forms)
gem 'nested_form', '~> 0.3.2', :git => 'https://github.com/ryanb/nested_form.git'

# A more robust alternative to the Webrick webserver
gem 'thin'

# To start the application with the Procfile (which uses thin), used by heroku if present
# For more info on how to deploy on heroku, see https://devcenter.heroku.com/articles/rails3
#gem 'foreman' # not required atm, heroku's default behaviour 'rails server' is good enough (we don't have multiple worker processes anyway)

# To use a Postgresql database
# System requirements: postgresql-9.1 postgresql-server-dev-9.1
gem 'pg'

# To use memcached-based fragment caching
# System requirements: memcached
# On Mac, try: brew install memcached
gem 'dalli'

# Replaces ActiveSupport::Memoization
gem 'memoist'

# To generate images (used for the images in the weeks_table)
# System requirements: libmagickwand-dev
# On Mac, try: brew install imagemagick
gem 'rmagick'  

# To generate PDF files from HTML
# Requires the executable 'wkhtmltopdf' to be available
gem 'pdfkit'

# For role based authorization à la current_person.is_admin_for? Saison.badi
gem 'authorization' 

# For email validation (inkl live check whether the domain exists)
gem 'email_veracity'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.6'
  gem 'coffee-rails', '~> 3.2.2'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer'

  gem 'uglifier', '~> 2.1.1'
end

#gem 'jquery-rails'
gem 'prototype-rails'
gem 'prototype_legacy_helper', '0.0.0', :git => 'https://github.com/rails/prototype_legacy_helper.git'

# To pop up a ruby debugger from within the code (start the app server with --debugger)
# Put a call to 'debugger' in your code. When executed, this method issues an irb prompt in the
# console where the server runs. You can now inspect the currently executed method's environment.
group :development do
  # gem 'ruby-debug-base19x', '~> 0.11.30.pre4' #maybe this line helps?
  # gem 'ruby-debug19',       require: 'ruby-debug'
  # gem 'ruby-debug-ide19'
end


gem 'rspec-rails', :group => [:test, :development]
group :test do
  gem 'factory_girl_rails'

  # For dealing with a warning about the version of nokogiri that is being loaded, see http://stackoverflow.com/a/10759560/1212000
  # (Plus: require 'nokogiri' in application.rb before any other libraries get the chance to load the wrong version.)

#  gem 'cucumber-rails', :require => false

  gem 'minitest-spec-rails'
  gem 'capybara_minitest_spec' # for capybara integration and spec matchers
  gem 'capybara-webkit' # for headless javascript tests; see http://stackoverflow.com/questions/11354656/error-error-error-installing-capybara-webkit
  gem 'database_cleaner' # as recommended by capybara

  gem 'guard-minitest' # On Mac OS X, make sure the rb-fsevent gem is installed so Guard can detect file changes.
  
  gem 'turn' # for fancy test outputs
end