module ActiveRecord
  module JSONB
    module Associations
      module JoinDependency
        module JoinAssociation #:nodoc:
          def build_constraint(klass, table, key, foreign_table, foreign_key)
            if reflection.options.key?(:foreign_store)
              Arel::Nodes::JSONBDashArrow.new(
                table, reflection.options[:foreign_store], key
              ).as_bigint.eq(foreign_table[foreign_key])
            else
              super
            end
          end
        end
      end
    end
  end
end
