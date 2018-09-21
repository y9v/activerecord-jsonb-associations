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
              if method_defined?(foreign_key)
                raise ActiveRecord::JSONB::Associations::
                        ConflictingAssociation,
                          "Association with foreign key :#{foreign_key} already "\
                          "exists on #{reflection.active_record.name}"
              end

              def #{foreign_key}=(value)
                #{reflection.options[:store]}['#{foreign_key}'] = value
              end

              def #{foreign_key}
                #{reflection.options[:store]}['#{foreign_key}']
              end

              def _read_attribute(attr_name)
                key = attr_name.to_s
                if key.ends_with?('_id') && #{reflection.options[:store]}.keys.include?(key)
                  #{reflection.options[:store]}[key]
                else
                  super
                end
              end

              def [](key)
                key = key.to_s
                if key.ends_with?('_id') &&
                    #{reflection.options[:store]}.keys.include?(key)
                  #{reflection.options[:store]}[key]
                else
                  super
                end
              end

              def []=(key, value)
                key = key.to_s
                if key.ends_with?('_id') &&
                    #{reflection.options[:store]}.keys.include?(key)
                  #{reflection.options[:store]}[key] = value
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
