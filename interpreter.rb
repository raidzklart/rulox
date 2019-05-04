require "./Expr"
require "./stmt"
require "./environment"
class Interpreter
    include Expr
    include Stmt

    def initialize
        @environment = Environment.new
    end

    def visit_literal_expr(expr)
        return expr.value
    end

    def visit_unary_expr(expr)
        right = evaluate(expr.right)
    
        case (expr.operator.type)
        when :minus
            check_number_operand(expr.operator, right)
            return right.to_f
        when :bang
            return !is_truthy?(right)
        end
        #Unreachable.                              
        return nil
    end

    def visit_variable_expr(expr)
        return @environment.get(expr.name)
    end
    
    # interpret used to take an expression as a parameter
    def interpret(statements)
        begin
            statements.each do |statement|
                execute(statement)
            end
        rescue => exception
            puts exception
        end
        # begin
        #     value = evaluate(expression)
        #     puts stringify(value)
        # rescue => exception
        #     puts exception
        # end
    end

    def check_number_operand(operator, operand)
        begin
            if (operand.class = Float) 
                return nil
            end
        rescue => exception
            puts "Operand must be a number. Exception: #{exception}"
        end
    end
    
    def check_number_operands(operator, left, right)
        begin
            if (left.class == Float && right.class == Float)
                return nil
            end
        rescue => exception
            puts "Operands must be numbers. Exception: #{exception}"
        end
    end

    def is_truthy?(object)
        if (object == nil or object.class == FalseClass)
            false
        else
            return true
        end
    end

    def is_equal(a, b)
        # nil is only equal to nil.               
        if (a == nil and b == nil) 
            return true
        elsif (a == nil)
            return false
        else
            return a == b
        end
    end

    def stringify(object)
        if (object == nil)
            return "=> nil"
        end
        if (object.class == Float)
            text = object.to_s
            if (text.end_with?(".0"))
                text = text[0..text.size - 3]
            end
            return "=> #{text}"
        end
        return "=> #{object}"
    end

    def visit_grouping_expr(expr)
        return evaluate(expr.expression)
    end

    def evaluate(expr)
        return expr.accept(self)
    end

    def execute(stmt)
        stmt.accept(self)
    end

    def execute_block(statements, environment)
        previous = @environment                                                         
        begin
            @environment = environment
            statements.each do |statement|
                execute(statement)
            end    
        rescue => exception
            puts exception
        ensure
            @environment = previous
        end
    end

    def visit_block_stmt(stmt)
        execute_block(stmt.statements, Environment.new(@environment))
        return nil
    end

    def visit_expression_stmt(stmt)
        evaluate(stmt.expression)
        return nil
    end

    def visit_print_stmt(stmt)
        value = evaluate(stmt.expression)
        puts stringify(value)
        return nil
    end

    def visit_var_stmt(stmt)
        if (stmt.initializer != nil)
            value = evaluate(stmt.initializer)
        end
        @environment.define(stmt.name.lexeme, value);
        return nil
    end

    def visit_assign_expr(expr)
        value = evaluate(expr.value)
        @environment.assign(expr.name, value)
        return value
    end

    def visit_binary_expr(expr)
        left = evaluate(expr.left)
        right = evaluate(expr.right)

        case (expr.operator.type)
        when :greater
            check_number_operands(expr.operator, left, right)
            return left.to_f > right.to_f
        when :greater_equal
            check_number_operands(expr.operator, left, right)
            return left.to_f >= right.to_f
        when :less
            check_number_operands(expr.operator, left, right)
            return left.to_f < right.to_f
        when :less_equal
            check_number_operands(expr.operator, left, right)
            return left.to_f <= right.to_f
        when :bang_equal
            return !is_equal(left, right)
        when :equal_equal
            return is_equal(left, right)
        when :minus
            check_number_operands(expr.operator, left, right)
            return left.to_f - right.to_f
        when :plus
            begin
                if left.class == Float and right.class == Float
                    return left.to_f + right.to_f
                end
                if (left.class == String && right.class == String)
                    return "#{left}#{right}"
                end
            rescue => exception
                puts "Operands must be two numbers or two strings. Exception: #{exception}"
            end
        when :slash
            check_number_operands(expr.operator, left, right)
            return left.to_f / right.to_f
        when :star
            check_number_operands(expr.operator, left, right)
            return left.to_f * right.to_f
        end
    
        #Unreachable.                                
        return nil
    end
end