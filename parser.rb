require "./Expr"
require "./stmt"
require "./environment"
class Parser
    include Expr
    include Stmt
    include Enumerable
    attr_reader :tokens, :current, :statements
    def initialize(tokens)
        @tokens = tokens
        @current = 0
    end

    def parse()
        statements = []
            while !is_at_end()
                statements += [declaration()]
                match(:semicolon)
            end
            # puts "Lox Parse Error: #{exception} #{@tokens}"
        return statements
        # begin
        #     return expression()
        # rescue => exception
        #     puts "Lox Parse Error: #{exception}"
        # end
    end

    def expression()
        return assignment()
    end

    def declaration()
        begin
            if (match(:id))
                return var_declaration()
            else
                return statement()
            end
        rescue => exception
            synchronize()
            raise exception
        end
    end

    def statement()
        if match(:print)
            return print_statement()
        elsif match(:left_brace)
            return Block.new(block())
        else
            return expression_statement()
        end
    end

    def print_statement()
        value = expression()
        consume(:semicolon, "Expect ';' after value.")
        return Print.new(value)
    end

    def var_declaration()
        name = consume(:id, "Expect variable name.")
        initializer = nil
        if (match(:equal))
            initializer = expression()
        end
        consume(:semicolon, "Expect ';' after variable declaration.")
        return Var.new(name, initializer)
    end

    def expression_statement()
        expr = expression()
        puts @tokens
        consume(:semicolon, "Expect ';' after expression.")
        return Expression.new(expr)
    end

    def block()
        statements = []
        while !check(:right_brace) && !is_at_end()
            statements += [declaration()]
        end
        consume(:right_brace, "Expect '}' after block.")
        return statements
    end

    def assignment()
        expr = equality()
    
        if (match(:equal))
            equals = previous()
            value = assignment()
            if (expr.class == Variable)
                name = expr.name
                return Assign.new(name, value)
            else
                raise "#{equals}, Invalid assignment target."
            end
        end
        return expr
    end

    def equality()                         
        expr = comparison()
    
        while match(:bang_equal, :equal_equal)
            operator = previous()                 
            right = comparison()
            expr =  Binary.new(expr, operator, right)
        end
        return expr
    end

    def comparison()
        expr = addition()

        while match(:greater, :greater_equal, :less, :less_equal)
            operator = previous()
            right = addition()
            expr = Binary.new(expr, operator, right)
        end
        return expr
    end

    def addition()
        expr = multiplication()

        while match(:minus, :plus)
            operator = previous()
            right = multiplication()
            expr = Binary.new(expr, operator, right)
        end
        return expr
    end

    def multiplication()
        expr = unary()

        while match(:slash, :star)
            operator = previous();                  
            right = unary();                         
            expr = Binary.new(expr, operator, right);
        end
        return expr
    end

    def unary()
        if match(:bang, :minus)
            operator = previous()
            right = unary()
            return Unary.new(operator, right)
        end
        return primary()
    end

    def primary()
        if match(:false)
            return Literal.new(false)
        elsif match(:true)
            return Literal.new(true) 
        elsif match(:nil)
            return Literal.new(nil)
        elsif match(:number, :string)
            return Literal.new(previous().literal)
        elsif match(:id)
            return Variable.new(previous())
        elsif match(:left_paren)
            expr = expression()
            consume(:right_paren, "Expect ')' after expression.")
            return Grouping.new(expr)
        else
            error(peek, "Invalid expression. #{@tokens}")
        end
    end

    def match(*types)
        types.each do |type|
            if check(type)
                advance()
                return true
            end
        end
        return false
    end

    def consume(type, message)
        if check(type)
            return advance()
        else
            error(peek(), message)
        end
    end
    
    def error(token, message)
        if token == :eof
            raise "Line: #{token.line}. Token: #{token} Error: #{message}"
        else
            raise "Line: #{token.line}. Token: #{token} Error: #{message}"
        end
    end

    def synchronize()
        advance
    
        while not is_at_end
            if previous.type == :semicolon
                return
            end

            case peek.type
                when :class, :fun, :var, :for, :if, :while, :return then
                return
            end
            advance
        end
    end

    def check(type)
        if is_at_end()
            false
        else
            peek.type == type
        end
    end

    def advance()
        if !is_at_end()
            @current += 1
        end
        return previous
    end

    def is_at_end()
        peek.type == :eof
    end

    def peek()
        @tokens[@current]
    end
    
    def previous()
        @tokens[@current-1]
    end
    
    def each(&block)
        @tokens.each do |member|
            block.call(member)
        end
    end
end