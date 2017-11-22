# activerecord-json-associations

[![Gem Version](https://badge.fury.io/rb/activerecord-jsonb-associations.svg)](https://badge.fury.io/rb/activerecord-jsonb-associations)

Use PostgreSQL JSONB fields to store association information of your models.

This gem was created as a solution to this [task](http://cultofmartians.com/tasks/active-record-jsonb-associations.html) from [EvilMartians](http://evilmartians.com).

**Requirements:**

- PostgreSQL (>= 9.6)

## Usage

### One-to-one and One-to-many associations

You can store all foreign keys of your model in one JSONB column, without having to create multiple columns:

```ruby
class Profile < ActiveRecord::Base
  # Setting additional :store option on :belongs_to association
  # enables saving of foreign ids in :extra JSONB column 
  belongs_to :user, store: :extra
end

class SocialProfile < ActiveRecord::Base
  belongs_to :user, store: :extra
end

class User < ActiveRecord::Base
  # Parent model association needs to specify :foreign_store
  # for associations with JSONB storage
  has_one :profile, foreign_store: :extra
  has_many :social_profiles, foreign_store: :extra
end
```

Foreign keys for association on one model have to be unique, even if they use different store column.

You can also use `add_references` in your migration to add JSONB column and index for it (if `index: true` option is set):

```ruby
add_reference :profiles, :users, store: :extra, index: true
```

### Many-to-many associations

You can also use JSONB columns on 2 sides of a HABTM association. This way you won't have to create a join table.

```ruby
class Label < ActiveRecord::Base
  # extra['user_ids'] will store associated user ids
  has_and_belongs_to_many :users, store: :extra
end

class User < ActiveRecord::Base
  # extra['label_ids'] will store associated label ids
  has_and_belongs_to_many :labels, store: :extra
end
```

#### Performance

Compared to regular associations, fetching models associated via JSONB column has no drops in performance.

Getting the count of connected records is ~35% faster with associations via JSONB (tested on associations with up to 10 000 connections).

Adding new connections is slightly faster with JSONB, for scopes up to 500 records connected to another record (total count of records in the table does not matter that much. If you have more then ~500 records connected to one record on average, and you want to add new records to the scope, JSONB associations will be slower then traditional:

<img src="https://github.com/lebedev-yury/activerecord-jsonb-associations/blob/master/doc/images/adding-associations.png?raw=true | width=500" alt="JSONB HAMTB is slower on adding associations" width="600">

On the other hand, unassociating models from a big amount of associated models if faster with JSONB HABTM as the associations count grows:

<img src="https://github.com/lebedev-yury/activerecord-jsonb-associations/blob/master/doc/images/deleting-associations.png?raw=true | width=500" alt="JSONB HAMTB is faster on removing associations" width="600">

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord-jsonb-associations'
```

And then execute:

```bash
$ bundle install
```

## Developing

To setup development environment, just run:

```bash
$ bin/setup
```

To run specs:

```bash
$ bundle exec rspec
```

To run benchmarks (that will take a while):

```bash
$ bundle exec rake benchmarks:habtm
```

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
