require 'bundler/setup'
require 'database_cleaner'
require 'factory_bot'

require 'activerecord/jsonb/associations'

require 'support/schema'
require 'support/models'
require 'support/factories'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
