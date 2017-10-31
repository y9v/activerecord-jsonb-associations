module ActiveRecord
  module JSONB
    module Associations
      module Builder
        module BelongsTo #:nodoc:
          def valid_options(options)
            super + [:store]
          end

          def define_accessors(mixin, reflection)
            if reflection.options.key?(:store)
              mixin.attribute reflection.foreign_key, :integer
              add_association_accessor_methods(mixin, reflection)
            end

            super
          end

          def add_association_accessor_methods(mixin, reflection)
            foreign_key = reflection.foreign_key.to_s

            mixin.class_eval <<-CODE, __FILE__, __LINE__ + 1
              def #{foreign_key}=(value)
                #{reflection.options[:store]}['#{foreign_key}'] = value
              end

              def #{foreign_key}
                #{reflection.options[:store]}['#{foreign_key}']
              end
            CODE
          end
        end
      end
    end
  end
end
