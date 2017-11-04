module ActiveRecord
  module JSONB
    module Associations
      module Preloader
        module HasMany #:nodoc:
          # rubocop:disable Metrics/AbcSize
          def records_for(ids)
            return super unless reflection.options.key?(:store)

            scope.where(
              Arel::Nodes::JSONBHashArrow.new(
                table,
                table[reflection.options[:store]],
                association_key_name.pluralize
              ).intersects_with(ids)
            )
          end
          # rubocop:enable Metrics/AbcSize

          def association_key_name
            super_value = super
            return super_value unless reflection.options.key?(:store)
            super_value.pluralize
          end

          # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          def associated_records_by_owner(preloader)
            return super unless reflection.options.key?(:store)

            records = load_records do |record|
              record[association_key_name].each do |owner_key|
                owner = owners_by_key[convert_key(owner_key)]
                association = owner.association(reflection.name)
                association.set_inverse_instance(record)
              end
            end

            owners.each_with_object({}) do |owner, result|
              result[owner] = records[convert_key(owner[owner_key_name])] || []
            end
          end
          # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
        end
      end
    end
  end
end
