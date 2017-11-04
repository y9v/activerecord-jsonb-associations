module Arel
  module Nodes
    class JSONBDashDoubleArrow < JSONBOperator #:nodoc:
      def operator
        '->>'
      end

      def as_int
        ::Arel::Nodes::NamedFunction.new('CAST', [as('int')])
      end
    end
  end
end
