module ActiveRecord
  module JSONB
    module Associations
      module Preloader
        module Association #:nodoc:
          # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          def records_for(ids)
            if reflection.options.key?(:foreign_store)
              scope.where(
                Arel::Nodes::JSONBDashArrow.new(
                  table,
                  reflection.options[:foreign_store],
                  association_key_name
                ).as_bigint.in(ids)
              )
            else
              scope.where(association_key_name => ids)
            end
          end
          # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
        end
      end
    end
  end
end
