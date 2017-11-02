module ActiveRecord
  module JSONB
    module Associations
      module AssociationScope #:nodoc:
        # rubocop:disable Metrics/MethodLength
        def last_chain_scope(scope, table, reflection, owner)
          reflection = reflection.instance_variable_get(:@reflection)

          if reflection.options.key?(:foreign_store)
            join_keys = reflection.join_keys
            value = transform_value(owner[join_keys.foreign_key])

            apply_jsonb_scope(
              scope, table, reflection.options[:foreign_store],
              join_keys.key, value
            )
          else
            super
          end
        end
        # rubocop:enable Metrics/MethodLength

        def apply_jsonb_scope(scope, table, jsonb_column, key, value)
          scope.where!(
            Arel::Nodes::JSONBDashArrow.new(
              table, jsonb_column, key
            ).eq(Arel::Nodes::BindParam.new)
          ).tap do |arel_scope|
            arel_scope.where_clause.binds << Relation::QueryAttribute.new(
              key.to_s, value, ActiveModel::Type::String.new
            )
          end
        end
      end
    end
  end
end
