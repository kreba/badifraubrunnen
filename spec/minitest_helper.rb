ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'  # Pulls in ..._path and ..._url helpers, turn and more
require 'minitest/autorun' # This pulls in minitest; it's not just for automated test running!
require 'capybara/rails'

# See http://babinho.net/2013/03/rails-integration-testing-with-minitestspec-and-capybara/
# and http://rubyflewtoo.blogspot.ch/2012/12/rails-32-minitest-spec-and-capybara.html
# and http://railscasts.com/episodes/327-minitest-with-rails
# and https://github.com/metaskills/minitest-spec-rails


# Switches to the javascript driver in integration tests
module WebkitJSDriver
  def require_js
    Capybara.current_driver = :webkit
  end

  def teardown
    super
    Capybara.current_driver = nil
  end
end

class ActionDispatch::IntegrationTest
  include Capybara::DSL
  include ActionView::Helpers::TranslationHelper
  include AuthenticatedTestHelper
  include WebkitJSDriver # switching Capybara driver for javascript tests
end

# This class will be used for evey spec whose description contains 'integration'
class BadiIntegrationTest < ActionDispatch::IntegrationTest
  register_spec_type(/integration/i, self) 
end

Turn.config.format = :outline