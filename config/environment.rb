# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

  # Authorization plugin for role based access control
  # You can override default authorization system constants here.

  # Can be 'object roles' or 'hardwired'
  AUTHORIZATION_MIXIN = "object roles"

  # NOTE : If you use modular controllers like '/admin/products' be sure 
  # to redirect to something like '/sessions' controller (with a leading slash)
  # as shown in the example below or you will not get redirected properly
  #
  # This can be set to a hash or to an explicit path like '/login'
  #
  LOGIN_REQUIRED_REDIRECTION = { :controller => '/sessions', :action => 'new' }
  PERMISSION_DENIED_REDIRECTION = { :controller => '/home', :action => 'index' }
  
  # The method your auth scheme uses to store the location to redirect back to 
  STORE_LOCATION_METHOD = :store_location
# end of Authorization plugin settings

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # The following line enables a cool profiling tool
  #config.gem 'fiveruns_tuneup'  -> edit deploy.rb, too!
  # as an alternative Rack::Bug could be used

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # config.cache_store = :mem_cache_store  # not used because it does not support fragment expiring by regexp

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/sweepers ) # I put them in the models folder now (crappy NetBeans!)

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_badi2010_session',
    :secret      => 'b779a5b29b95964a8b6d1ae92dadb4aa5d37aab43f51e61c4a8b5ca8f025bad87592f39f0f07512ca7006fc708a6151cbad141c3a138d53476a7636c428b76af'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Change the location where cached fragments are stored (default: .../public/)
  config.action_controller.page_cache_directory = RAILS_ROOT + "/public/cache/"
  #(I'm not using page caching atm;
  # action and fragment caching do not depend on this setting (they are in-memory per default))

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :account_observer, :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc

  # The default default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  config.i18n.default_locale = :de_ch
end
