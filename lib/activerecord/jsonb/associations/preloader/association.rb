module ActiveRecord
  module JSONB
    module Associations
      module Preloader
        module Association #:nodoc:
          def records_for(ids)
            return super unless reflection.options.key?(:foreign_store)

            scope.where(
              Arel::Nodes::JSONBHashArrow.new(
                table,
                table[reflection.options[:foreign_store]],
                association_key_name
              ).intersects_with(ids)
            )
          end
        end
      end
    end
  end
end
