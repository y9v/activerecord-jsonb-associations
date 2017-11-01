module ActiveRecord
  module JSONB
    module Associations
      module Preloader
        module HasOne #:nodoc:
          def records_for(ids)
            if reflection.options.key?(:foreign_store)
              scope.where(
                "(#{reflection.options[:foreign_store]} ->> "\
                "'#{association_key_name}')::integer IN (?)",
                ids
              )
            else
              scope.where(association_key_name => ids)
            end
          end
        end
      end
    end
  end
end
