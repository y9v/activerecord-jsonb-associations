module ActiveRecord
  module JSONB
    module Associations
      module AssociationScope #:nodoc:
        def last_chain_scope(scope, table, reflection, owner)
          reflection = reflection.instance_variable_get(:@reflection)

          if reflection.options.key?(:foreign_store)
            join_keys = reflection.join_keys
            value = transform_value(owner[join_keys.foreign_key])

            if value.is_a?(Integer)
              scope = apply_jsonb_scope(
                scope, table, reflection.options[:foreign_store],
                join_keys.key, value
              )
            end

            scope
          else
            super
          end
        end

        def apply_jsonb_scope(scope, table, jsonb_column, key, value)
          scope.where!(
            "(#{table.name}.#{jsonb_column}->>'#{key}')::int = :id",
            id: value
          )
        end
      end
    end
  end
end
