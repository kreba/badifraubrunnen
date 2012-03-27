source 'https://rubygems.org'

gem 'rails', '3.2.2'

# A more robust alternative to the Webrick webserver
gem 'thin'

# To start the application with the Procfile (which uses thin), used by heroku if present
# For more info on how to deploy on heroku, see https://devcenter.heroku.com/articles/rails3
#gem 'foreman' # not required atm, heroku's default behaviour 'rails server' is good enough (we don't have multiple worker processes anyway)

# To use a Postgresql database
gem 'pg'

# To generate images (used for the images in the weeks_table)
gem 'rmagick'  # Requires system libraries!

# For role based authorization à la current_person.is_admin_for? Saison.badi
gem 'authorization' 

# For email validation (inkl live check whether the domain exists)
gem 'email_veracity'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'
end

#gem 'jquery-rails'
gem 'prototype'
gem 'prototype_legacy_helper', '0.0.0', :git => 'git://github.com/rails/prototype_legacy_helper.git'

# To pop up a ruby debugger from within the code (start the app server with --debugger)
# (Put a call to 'debugger' in your code. When executed, this method issues an irb prompt in the
# console where the server runs. You can now inspect the currently executed method's environment.)
group :development do
###  gem 'ruby-debug-base19x', '~> 0.11.30.pre4' #maybe this line helps?
##  gem 'ruby-debug19',       :require => 'ruby-debug'
##  gem 'ruby-debug-ide19'
end

