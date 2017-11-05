module Arel
  module Nodes
    class JSONBDashDoubleArrow < JSONBOperator #:nodoc:
      def operator
        '->>'
      end
    end
  end
end
