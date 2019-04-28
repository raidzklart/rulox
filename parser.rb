require "./Expr"
class Parser
    include Expr
    include Enumerable
    attr_reader :tokens, :current
    def initialize(tokens)
        @tokens = tokens
        @current = 0
    end

    def parse()
        begin
            return expression()
        rescue => exception
            puts "Lox Parse Error: #{exception}"
        end
    end

    def expression()
        return equality()
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
        elsif match(:left_paren)
            expr = expression()
            consume(:right_paren, "Expect ')' after expression.")
            return Grouping.new(expr)
        else
            error(peek, "Invalid expression.")
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