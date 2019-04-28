require "./lox"
require "./token"
require "./parser"
class Scanner
    include Enumerable
    attr_reader :tokens
    KEYWORDS = [
        "and",
        "class",
        "else",
        "false",
        "for",
        "fn",
        "if",
        "nil",
        "or",
        "return",
        "super",
        "self",
        "true",
        "let",
        "while",
      ]
    def initialize(source)
        @source = source
        @tokens = []
        @start = 0                             
        @current = 0                            
        @line = 1
    end

    def scan_tokens
        while !is_at_end?
            #We are at the beginning of the next lexeme.
            @start = @current
            scan_token()
        end
        @tokens.append Token.new(:eof, "", nil, @line)
        return @tokens
    end

    def scan_token
        c = advance()
        case c
        when '('
            add_token(:left_paren)
        when ')'
            add_token(:right_paren)
        when '{'
            add_token(:left_brace)
        when '}'
            add_token(:right_brace)
        when ','
            add_token(:comma)
        when '.'
            add_token(:dot)
        when '-'
            add_token(:minus)
        when '+'
            add_token(:plus)
        when ';'
            add_token(:semicolon)
        when '*'
            add_token(:star)
        when '!' 
            add_token(match('=') ? :bang_equal : :bang)
        when '=' 
            add_token(match('=') ? :equal_equal : :equal)
        when '<' 
            add_token(match('=') ? :less_equal : :less)
        when '>' 
            add_token(match('=') ? :greater_equal : :greater)
        when '/'
            if match('/')
                while(peek() != '\n') && (!is_at_end?)
                    advance()
                end
            else
                add_token(:slash)
            end
        when ' ', '\r', '\t'
            nil
        when '\n'
            @line += 1
        when '"'
            string()
        else
            if is_digit(c)
                number()
            elsif is_alphanumeric(c)
                identifier()
            else
                Lox.error(@line, "Unexpected character.")
            end
        end
    end

    def identifier()
        while is_alphanumeric(peek)
            advance()
        end
        text = @source[@start, @current-@start]
        type = :id
        if KEYWORDS.include?(text)
            type = text.to_sym
        end
        add_token(type)
    end

    def string
        while peek() != '"' and not is_at_end?
            if peek() == '\n'
                @line+= 1                         
            end
            advance()
        end
        #Unterminated string.
        raise Lox.error(@line, "Unterminated string.") if is_at_end?
        #The closing ".
        advance()
        #Trim the surrounding quotes.
        value = @source[(@start+1), (@current-1)-(@start+1)]
        add_token(:string, value)
    end
    
    def is_digit(c)
        c >= '0' and c <= '9'
    end

    def number()
        while is_digit(peek)
          advance
        end
    
        if peek == '.' and is_digit(peek_next)
          advance
    
          while is_digit(peek)
            advance
          end
        end
    
        add_token(:number, Float(@source[@start, @current-@start]))
    end

    def is_at_end?
        @current >= @source.length
    end
    
    def advance
        @current += 1
        return @source[@current-1]
    end

    def add_token(type, literal=nil)
        @tokens << Token.new(type, @source[@start, @current-@start], literal, @line)
    end

    def match(expected)
        return false  if (@source[@current] != expected) 
        return false if is_at_end?
        @current+=1
        return true
    end

    def peek
        if is_at_end?
            return '\0'
        else
            return @source[@current]
        end
    end

    def peek_next
        if @current + 1 >= @source.length
            "\0"
        else
            @source[@current+1]
        end
    end

    def is_alpha(c)
        (c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z') or c == '_'
    end

    def is_alphanumeric(c)
        is_alpha(c) or is_digit(c)
    end

    def each(&block)
        @tokens.each do |member|
            block.call(member)
        end
    end
end