module Arel
  module Nodes
    class JSONBHashArrow < Arel::Nodes::JSONBOperator #:nodoc:
      def operator
        '#>'
      end

      def right_side
        ::Arel::Nodes::SqlLiteral.new("'{#{name}}'")
      end

      def contains(value)
        Arel::Nodes::JSONBAtArrow.new(relation, self, value)
      end

      def intersects_with(array)
        ::Arel::Nodes::InfixOperation.new(
          '>',
          ::Arel::Nodes::NamedFunction.new(
            'jsonb_array_length',
            [Arel::Nodes::JSONBDoublePipe.new(relation, self, array)]
          ),
          0
        )
      end
    end
  end
end
