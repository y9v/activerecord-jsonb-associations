module ActiveRecord
  module JSONB
    module Associations
      module Preloader
        module Association #:nodoc:
          # rubocop:disable Metrics/AbcSize
          def records_for(ids)
            return super unless reflection.options.key?(:foreign_store)

            scope.where(
              Arel::Nodes::JSONBDashDoubleArrow.new(
                table,
                table[reflection.options[:foreign_store]],
                association_key_name
              ).as_int.in(ids)
            )
          end
          # rubocop:enable Metrics/AbcSize
        end
      end
    end
  end
end
