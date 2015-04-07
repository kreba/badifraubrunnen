source 'https://rubygems.org'
ruby '2.1.5' #keep in sync with .ruby-version

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

# Dalli: To use memcached-based fragment caching
# System requirements: memcached
# On Mac, try: brew install memcached
gem 'memcachier'
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
gem 'prototype_legacy_helper', '0.0.0', git: 'git://github.com/rails/prototype_legacy_helper.git'

#gem 'rspec-rails', :group => [:test, :development]

group :test do
  gem 'factory_girl_rails'

  gem 'cucumber-rails', :require => false

  gem 'minitest-spec-rails'
  gem 'capybara_minitest_spec' # for capybara integration and spec matchers
  gem 'capybara-webkit'        # for headless javascript tests; see http://stackoverflow.com/questions/11354656/error-error-error-installing-capybara-webkit

  # TODO: make sure the database cleaner is working as expected (railscast shows some manual setup)
  gem 'database_cleaner' # as recommended by capybara & cucumber-rails; 

  gem 'launchy' # For save_and_open_page

  gem 'guard-minitest', :git => 'https://github.com/guard/guard-minitest' # Guard: On Mac OS X, make sure the rb-fsevent gem is installed so Guard can detect file changes.
  gem 'guard-cucumber'
  
  gem 'spring'         # !!As of now, only supports MiniTest::Unit (not MiniTest::Spec)!! Faster testing thanks to pre-loading of (big chunks of) the environment. (Alternatives: spork, zeus, commands)
  
  gem 'turn' # for fancy test outputs
end
