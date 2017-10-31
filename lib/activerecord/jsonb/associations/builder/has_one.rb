module ActiveRecord
  module JSONB
    module Associations
      module Builder
        module HasOne #:nodoc:
          def valid_options(options)
            super + [:foreign_store]
          end
        end
      end
    end
  end
end
