require 'bundler/setup'
require 'database_cleaner'

require 'activerecord/jsonb/associations'

require 'support/helpers/queries_counter'
require 'support/schema'
require 'support/models'

RSpec.configure do |config|
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
