module ActiveRecord
  module JSONB
    module ConnectionAdapters
      module ReferenceDefinition #:nodoc:
        # rubocop:disable Lint/UnusedMethodArgument, Metrics/ParameterLists
        def initialize(
          name,
          polymorphic: false,
          index: true,
          foreign_key: false,
          type: :bigint,
          store: false,
          **options
        )
          @store = store

          super(
            name,
            polymorphic: false,
            index: true,
            foreign_key: false,
            type: :bigint,
            **options
          )
        end
        # rubocop:enable Lint/UnusedMethodArgument, Metrics/ParameterLists

        def add_to(table)
          return super unless store

          table.column(store, :jsonb, null: false, default: {})

          return unless index

          column_names.each do |column_name|
            table.index(
              "(#{store}->'#{column_name}')",
              using: :gin,
              name: "index_#{table.name}_on_#{store}_#{column_name}"
            )
          end
        end

        protected

        attr_reader :store
      end
    end
  end
end
