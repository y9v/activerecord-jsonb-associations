module ActiveRecord
  module JSONB
    module Associations
      module JoinDependency
        module JoinAssociation #:nodoc:
          # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          def build_constraint(klass, table, key, foreign_table, foreign_key)
            if reflection.options.key?(:foreign_store)
              Arel::Nodes::JSONBDashDoubleArrow.new(
                table, table[reflection.options[:foreign_store]], key
              ).eq("#{foreign_table}.#{foreign_key}")
            elsif reflection.options.key?(:store)
              Arel::Nodes::JSONBHashArrow.new(
                table,
                table[reflection.options[:store]],
                key.pluralize
              ).contains("#{foreign_table}.#{foreign_key}")
            else
              super
            end
          end
          # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
        end
      end
    end
  end
end
