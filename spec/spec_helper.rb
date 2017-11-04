require 'bundler/setup'
require 'database_cleaner'
require 'factory_bot'
require 'pry'

require 'activerecord/jsonb/associations'

require 'support/helpers/queries_counter'
require 'support/schema'
require 'support/models'
require 'support/factories'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.include Helpers::QueriesCounter

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
