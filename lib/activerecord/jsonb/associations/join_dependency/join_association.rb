module ActiveRecord
  module JSONB
    module Associations
      module JoinDependency
        module JoinAssociation #:nodoc:
          # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          def build_constraint(klass, table, key, foreign_table, foreign_key)
            if reflection.options.key?(:foreign_store)
              build_eq_constraint(
                table, table[reflection.options[:foreign_store]],
                key, foreign_table, foreign_key
              )
            elsif reflection.options.key?(:store) && reflection.belongs_to?
              build_eq_constraint(
                foreign_table, foreign_table[reflection.options[:store]],
                foreign_key, table, key
              )
            elsif reflection.options.key?(:store) # && reflection.has_one?
              build_contains_constraint(
                table, table[reflection.options[:store]],
                key.pluralize, foreign_table, foreign_key
              )
            else
              super
            end
          end
          # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

          def build_eq_constraint(
            table, jsonb_column, key, foreign_table, foreign_key
          )
            Arel::Nodes::JSONBDashDoubleArrow.new(table, jsonb_column, key).eq(
              ::Arel::Nodes::SqlLiteral.new(
                "CAST(#{foreign_table.name}.#{foreign_key} AS text)"
              )
            )
          end

          def build_contains_constraint(
            table, jsonb_column, key, foreign_table, foreign_key
          )
            Arel::Nodes::JSONBHashArrow.new(table, jsonb_column, key).contains(
              ::Arel::Nodes::SqlLiteral.new(
                "jsonb_build_array(#{foreign_table.name}.#{foreign_key})"
              )
            )
          end
        end
      end
    end
  end
end
