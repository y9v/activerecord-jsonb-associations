require 'yaml'
require 'pg'

db_config = YAML.load_file(
  File.expand_path('../../config/database.yml', __FILE__)
).fetch('pg')

ActiveRecord::Base.establish_connection(
  adapter: 'postgresql',
  database: 'activerecord_jsonb_associations_test',
  username: db_config.fetch('username'),
  min_messages: 'warning'
)

ActiveRecord::Migration.verbose = false

# rubocop:disable Metrics/BlockLength
ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.jsonb :extra, null: false, default: {}
    t.timestamps null: false
  end

  create_table :goods_suppliers, force: true do |t|
    t.timestamps null: false
  end

  create_table :profiles, force: true do |t|
    t.belongs_to :user, null: false
    t.timestamps null: false
  end

  create_table :accounts, force: true do |t|
    t.references :user, store: :extra, index: true
    t.references :supplier, store: :extra, index: true
    t.timestamps null: false
  end

  create_table :photos, force: true do |t|
    t.belongs_to :user
    t.timestamps null: false
  end

  create_table :invoice_photos, force: true do |t|
    t.references :supplier, store: :extra, index: true
    t.timestamps null: false
  end

  create_table :social_profiles, force: true do |t|
    t.references :user, store: :extra, index: true
    t.timestamps null: false
  end

  create_table :labels, force: true do |t|
    t.jsonb :extra, null: false, default: {}
    t.timestamps null: false
  end

  create_table :groups, force: true do |t|
    t.timestamps null: false
  end

  create_table :groups_users, force: true do |t|
    t.belongs_to :user
    t.belongs_to :group
  end
end
# rubocop:enable Metrics/BlockLength
