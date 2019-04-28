module Expr
class Visitor
    def visit_binary_expr(expr)
    end
    def visit_grouping_expr(expr)
    end
    def visit_literal_expr(expr)
    end
    def visit_unary_expr(expr)
    end
end
  def accept(visitor)
    end
  class Binary
    include Expr
     attr_reader :left
     attr_reader :operator
     attr_reader :right
    def initialize(left, operator, right)
      @left = left
      @operator = operator
      @right = right
    end
    def accept(visitor)
        return visitor.visit_binary_expr(self)
    end
  end
  class Grouping
    include Expr
     attr_reader :expression
    def initialize(expression)
      @expression = expression
    end
    def accept(visitor)
        return visitor.visit_grouping_expr(self)
    end
  end
  class Literal
    include Expr
     attr_reader :value
    def initialize(value)
      @value = value
    end
    def accept(visitor)
        return visitor.visit_literal_expr(self)
    end
  end
  class Unary
    include Expr
     attr_reader :operator
     attr_reader :right
    def initialize(operator, right)
      @operator = operator
      @right = right
    end
    def accept(visitor)
        return visitor.visit_unary_expr(self)
    end
  end
    def accept(visitor)
    end
end
