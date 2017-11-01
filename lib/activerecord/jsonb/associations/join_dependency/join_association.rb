module ActiveRecord
  module JSONB
    module Associations
      module JoinDependency
        module JoinAssociation #:nodoc:
          # rubocop:disable Metrics/MethodLength
          def build_constraint(klass, table, key, foreign_table, foreign_key)
            if reflection.options.key?(:foreign_store)
              operation = Arel::Nodes::InfixOperation.new(
                '->>',
                table[reflection.options[:foreign_store]],
                Arel::Nodes::SqlLiteral.new("'supplier_id'")
              )
              typecasted_operation = Arel::Nodes::NamedFunction.new(
                'CAST', [operation.as('bigint')]
              )
              constraint = typecasted_operation.eq(foreign_table[foreign_key])
              constraint
            else
              super
            end
          end
          # rubocop:enable Metrics/MethodLength
        end
      end
    end
  end
end
