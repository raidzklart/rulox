module Stmt
class Visitor
    def visit_block_stmt(stmt)
    end
    def visit_expression_stmt(stmt)
    end
    def visit_print_stmt(stmt)
    end
    def visit_var_stmt(stmt)
    end
end
  def accept(visitor)
    end
  class Block
    include Stmt
     attr_reader :statements
    def initialize(statements)
      @statements = statements
    end
    def accept(visitor)
        return visitor.visit_block_stmt(self)
    end
  end
  class Expression
    include Stmt
     attr_reader :expression
    def initialize(expression)
      @expression = expression
    end
    def accept(visitor)
        return visitor.visit_expression_stmt(self)
    end
  end
  class Print
    include Stmt
     attr_reader :expression
    def initialize(expression)
      @expression = expression
    end
    def accept(visitor)
        return visitor.visit_print_stmt(self)
    end

    def to_s
      "#{@expression}"
    end
  end
  class Var
    include Stmt
     attr_reader :name
     attr_reader :initializer
    def initialize(name, initializer)
      @name = name
      @initializer = initializer
    end
    def accept(visitor)
        return visitor.visit_var_stmt(self)
    end
    def to_s
      "#{@name}, #{@initializer}"
    end
  end
    def accept(visitor)
    end
end
