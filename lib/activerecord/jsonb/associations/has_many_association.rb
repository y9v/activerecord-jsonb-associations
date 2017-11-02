module ActiveRecord
  module JSONB
    module Associations
      module HasManyAssociation #:nodoc:
        def delete_count(method, scope)
          if method != :delete_all && reflection.options.key?(:foreign_store)
            scope.update_all(
              "#{reflection.options[:foreign_store]} = "\
              "#{reflection.options[:foreign_store]} #- "\
              "'{#{reflection.foreign_key}}'"
            )
          else
            super
          end
        end
      end
    end
  end
end
