module ActiveRecord
  module JSONB
    module Associations
      module Builder
        module HasMany #:nodoc:
          def valid_options(options)
            super + %i[store foreign_store]
          end

          def define_accessors(mixin, reflection)
            if reflection.options.key?(:store)
              add_association_accessor_methods(mixin, reflection)
            end

            super
          end

          def add_association_accessor_methods(mixin, reflection)
            mixin.class_eval <<-CODE, __FILE__, __LINE__ + 1
              def [](key)
                key = key.to_s
                if key.ends_with?('_ids') &&
                    #{reflection.options[:store]}.keys.include?(key)
                  #{reflection.options[:store]}[key]
                else
                  super
                end
              end
            CODE
          end
        end
      end
    end
  end
end
