module ActiveRecord
  module JSONB
    module Associations
      module HasManyAssociation #:nodoc:
        def ids_reader
          return super unless reflection.options.key?(:store)

          Array(
            owner[reflection.options[:store]][
              "#{reflection.name.to_s.singularize}_ids"
            ]
          )
        end

        # rubocop:disable Naming/AccessorMethodName
        def set_owner_attributes(record)
          return super unless reflection.options.key?(:store)

          creation_attributes.each do |key, value|
            if key == reflection.options[:store]
              set_store_attributes(record, key, value)
            else
              record[key] = value
            end
          end
        end
        # rubocop:enable Naming/AccessorMethodName

        def set_store_attributes(record, store_column, attributes)
          attributes.each do |key, value|
            if value.is_a?(Array)
              record[store_column][key] ||= []
              record[store_column][key] =
                record[store_column][key].concat(value).uniq
            else
              record[store_column] = value
            end
          end
        end

        # rubocop:disable Metrics/AbcSize
        def creation_attributes
          return super unless reflection.options.key?(:store)

          attributes = {}
          jsonb_store = reflection.options[:store]
          attributes[jsonb_store] ||= {}
          attributes[jsonb_store][reflection.foreign_key.pluralize] = []
          attributes[jsonb_store][reflection.foreign_key.pluralize] <<
            owner[reflection.active_record_primary_key]

          attributes
        end
        # rubocop:enable Metrics/AbcSize

        # rubocop:disable Metrics/AbcSize
        def create_scope
          super.tap do |scope|
            next unless options.key?(:store)

            key = reflection.foreign_key.pluralize
            scope[options[:store].to_s] ||= {}
            scope[options[:store].to_s][key] ||= []
            scope[options[:store].to_s][key] << owner[
              reflection.active_record_primary_key
            ]
          end
        end
        # rubocop:enable Metrics/AbcSize

        # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        def insert_record(record, validate = true, raise = false)
          super.tap do |super_result|
            next unless options.key?(:store)
            next unless super_result

            key = "#{record.model_name.singular}_ids"
            jsonb_column = options[:store]

            owner.class.where(
              owner.class.primary_key => owner[owner.class.primary_key]
            ).update_all(%(
              #{jsonb_column} = jsonb_set(#{jsonb_column}, '{#{key}}',
              coalesce(#{jsonb_column}->'#{key}', '[]'::jsonb) ||
              '[#{record[klass.primary_key]}]'::jsonb)
            ))
          end
        end
        # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

        def delete_records(records, method)
          return super unless options.key?(:store)
          super(records, :delete)
        end

        # rubocop:disable Metrics/AbcSize
        def delete_count(method, scope)
          store = reflection.options[:foreign_store] ||
                  reflection.options[:store]
          return super if method == :delete_all || !store

          if reflection.options.key?(:foreign_store)
            remove_jsonb_foreign_id_on_belongs_to(store, reflection.foreign_key)
          else
            remove_jsonb_foreign_id_on_habtm(
              store, reflection.foreign_key.pluralize, owner.id
            )
          end
        end
        # rubocop:enable Metrics/AbcSize

        def remove_jsonb_foreign_id_on_belongs_to(store, foreign_key)
          scope.update_all("#{store} = #{store} #- '{#{foreign_key}}'")
        end

        def remove_jsonb_foreign_id_on_habtm(store, foreign_key, owner_id)
          # PostgreSQL can only delete jsonb array elements by text or index.
          # Therefore we have to convert the jsonb array to PostgreSQl array,
          # remove the element, and convert it back
          scope.update_all(
            %(
              #{store} = jsonb_set(#{store}, '{#{foreign_key}}',
                to_jsonb(
                  array_remove(
                    array(select * from jsonb_array_elements(
                      (#{store}->'#{foreign_key}'))),
                    '#{owner_id}')))
            )
          )
        end
      end
    end
  end
end
