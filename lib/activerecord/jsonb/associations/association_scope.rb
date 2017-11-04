module ActiveRecord
  module JSONB
    module Associations
      module AssociationScope #:nodoc:
        # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        def last_chain_scope(scope, table, owner_reflection, owner)
          reflection = owner_reflection.instance_variable_get(:@reflection)
          return super unless reflection

          join_keys = reflection.join_keys
          key = join_keys.key
          value = transform_value(owner[reflection.join_keys.foreign_key])

          if reflection.options.key?(:foreign_store)
            apply_jsonb_scope(
              scope,
              jsonb_equality(table, reflection.options[:foreign_store], key),
              key, value
            )
          elsif reflection && reflection.options.key?(:store)
            pluralized_key = key.pluralize

            apply_jsonb_scope(
              scope,
              jsonb_containment(
                table, reflection.options[:store], pluralized_key
              ),
              pluralized_key, value
            )
          else
            super
          end
        end
        # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

        def apply_jsonb_scope(scope, predicate, key, value)
          scope.where!(predicate).tap do |arel_scope|
            arel_scope.where_clause.binds << Relation::QueryAttribute.new(
              key.to_s, value, ActiveModel::Type::String.new
            )
          end
        end

        def jsonb_equality(table, jsonb_column, key)
          Arel::Nodes::JSONBDashDoubleArrow.new(
            table, table[jsonb_column], key
          ).eq(Arel::Nodes::BindParam.new)
        end

        def jsonb_containment(table, jsonb_column, key)
          Arel::Nodes::JSONBHashArrow.new(
            table, table[jsonb_column], key
          ).contains(Arel::Nodes::BindParam.new)
        end
      end
    end
  end
end
