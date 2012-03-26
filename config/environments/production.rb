# Settings specified here will take precedence over those in config/environment.rb

# Specify that your app is run in a subdirectory. You will want to use
# this for example if you are using passenger's RailsBaseURI directive
##config.action_controller.relative_url_root = "/badi2010"

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

#config.observers = [DaySweeper]

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

