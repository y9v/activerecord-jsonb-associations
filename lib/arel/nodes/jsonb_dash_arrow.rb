module Arel
  module Nodes
    class JSONBDashArrow < ::Arel::Nodes::InfixOperation #:nodoc:
      attr_reader :relation
      attr_reader :name

      def initialize(table, jsonb_column, key)
        @relation = table
        @name = key

        super(
          '->>',
          table[jsonb_column],
          ::Arel::Nodes::SqlLiteral.new("'#{key}'")
        )
      end

      def as_bigint
        ::Arel::Nodes::NamedFunction.new('CAST', [as('bigint')])
      end
    end
  end
end
