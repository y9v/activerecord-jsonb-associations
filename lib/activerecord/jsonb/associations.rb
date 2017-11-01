require 'active_record'
require 'pry'

require 'activerecord/jsonb/associations/builder/belongs_to'
require 'activerecord/jsonb/associations/builder/has_one'
require 'activerecord/jsonb/associations/belongs_to_association'
require 'activerecord/jsonb/associations/has_one_association'
require 'activerecord/jsonb/associations/association_scope'
require 'activerecord/jsonb/associations/preloader/has_one'
require 'activerecord/jsonb/associations/join_dependency/join_association'

module ActiveRecord #:nodoc:
  module JSONB #:nodoc:
    module Associations #:nodoc:
      class ConflictingAssociation < StandardError; end
    end
  end
end

ActiveSupport.on_load :active_record do
  ::ActiveRecord::Associations::Builder::BelongsTo.extend(
    ActiveRecord::JSONB::Associations::Builder::BelongsTo
  )

  ::ActiveRecord::Associations::Builder::HasOne.extend(
    ActiveRecord::JSONB::Associations::Builder::HasOne
  )

  ::ActiveRecord::Associations::BelongsToAssociation.prepend(
    ActiveRecord::JSONB::Associations::BelongsToAssociation
  )

  ::ActiveRecord::Associations::HasOneAssociation.prepend(
    ActiveRecord::JSONB::Associations::HasOneAssociation
  )

  ::ActiveRecord::Associations::AssociationScope.prepend(
    ActiveRecord::JSONB::Associations::AssociationScope
  )

  ::ActiveRecord::Associations::Preloader::HasOne.prepend(
    ActiveRecord::JSONB::Associations::Preloader::HasOne
  )

  ::ActiveRecord::Associations::JoinDependency::JoinAssociation.prepend(
    ActiveRecord::JSONB::Associations::JoinDependency::JoinAssociation
  )
end
