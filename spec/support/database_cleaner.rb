# Following http://devblog.avdi.org/2012/08/31/configuring-database_cleaner-with-rails-rspec-capybara-and-selenium/

# TODO: Do we have to do something like "config.use_transactional_fixtures = false"? (needed for DatabaseCleaner + RSpec)

class MiniTest::Spec
  before :suite do
    DatabaseCleaner.clean_with :truncation 
  end
  before :each do
    DatabaseCleaner.strategy = :transaction
  end
  # before :each, js: true do TODO: check whether this is required with minitest, too (was with RSpec)
  #   DatabaseCleaner.strategy = :transaction
  # end
  before :each do
    DatabaseCleaner.start
  end
  after :each do
    DatabaseCleaner.clean
  end
end
