module Arel
  module Nodes
    class JSONBAtArrow < JSONBOperator #:nodoc:
      def operator
        '@>'
      end

      def right_side
        return name if name.is_a?(::Arel::Nodes::BindParam) ||
                       name.is_a?(::Arel::Nodes::SqlLiteral)

        ::Arel::Nodes::SqlLiteral.new("'#{name.to_json}'")
      end
    end
  end
end
