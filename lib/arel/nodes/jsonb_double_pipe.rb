module Arel
  module Nodes
    class JSONBDoublePipe < JSONBOperator #:nodoc:
      def operator
        '||'
      end

      def right_side
        return name if name.is_a?(::Arel::Nodes::BindParam)
        ::Arel::Nodes::SqlLiteral.new("'#{name.to_json}'")
      end
    end
  end
end
