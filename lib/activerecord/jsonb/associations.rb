require 'active_record'
require 'pry'

require 'arel/nodes/jsonb_dash_arrow'
require 'activerecord/jsonb/associations/builder/belongs_to'
require 'activerecord/jsonb/associations/builder/has_one'
require 'activerecord/jsonb/associations/builder/has_many'
require 'activerecord/jsonb/associations/belongs_to_association'
require 'activerecord/jsonb/associations/association'
require 'activerecord/jsonb/associations/has_many_association'
require 'activerecord/jsonb/associations/association_scope'
require 'activerecord/jsonb/associations/preloader/association'
require 'activerecord/jsonb/associations/join_dependency/join_association'
require 'activerecord/jsonb/connection_adapters/reference_definition'

module ActiveRecord #:nodoc:
  module JSONB #:nodoc:
    module Associations #:nodoc:
      class ConflictingAssociation < StandardError; end
    end
  end
end

# rubocop:disable Metrics/BlockLength
ActiveSupport.on_load :active_record do
  ::ActiveRecord::Associations::Builder::BelongsTo.extend(
    ActiveRecord::JSONB::Associations::Builder::BelongsTo
  )

  ::ActiveRecord::Associations::Builder::HasOne.extend(
    ActiveRecord::JSONB::Associations::Builder::HasOne
  )

  ::ActiveRecord::Associations::Builder::HasMany.extend(
    ActiveRecord::JSONB::Associations::Builder::HasMany
  )

  ::ActiveRecord::Associations::Association.prepend(
    ActiveRecord::JSONB::Associations::Association
  )

  ::ActiveRecord::Associations::BelongsToAssociation.prepend(
    ActiveRecord::JSONB::Associations::BelongsToAssociation
  )

  ::ActiveRecord::Associations::HasManyAssociation.prepend(
    ActiveRecord::JSONB::Associations::HasManyAssociation
  )

  ::ActiveRecord::Associations::AssociationScope.prepend(
    ActiveRecord::JSONB::Associations::AssociationScope
  )

  ::ActiveRecord::Associations::Preloader::Association.prepend(
    ActiveRecord::JSONB::Associations::Preloader::Association
  )

  ::ActiveRecord::Associations::JoinDependency::JoinAssociation.prepend(
    ActiveRecord::JSONB::Associations::JoinDependency::JoinAssociation
  )

  ::ActiveRecord::ConnectionAdapters::ReferenceDefinition.prepend(
    ActiveRecord::JSONB::ConnectionAdapters::ReferenceDefinition
  )
end
# rubocop:enable Metrics/BlockLength
