module Arel
  module Nodes
    class JSONBOperator < ::Arel::Nodes::InfixOperation #:nodoc:
      attr_reader :relation
      attr_reader :name

      def initialize(relation, left_side, key)
        @relation = relation
        @name = key

        super(operator, left_side, right_side)
      end

      def right_side
        ::Arel::Nodes::SqlLiteral.new("'#{name}'")
      end

      def operator
        raise NotImplementedError,
              'Subclasses must implement an #operator method'
      end
    end
  end
end
