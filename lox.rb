require "./scanner.rb"
require "./token"
require "./parser"
require "./ast_printer"
class Lox
    include Expr
    @had_error = false

    def run_file(path)
        run(File.read(path))
        #Indicate an error in the exit code.
        exit(65) if @had_error
    end

    def run_prompt
        loop do
            print "Lox > "
            run(gets.chomp)
            @had_error = false
        end
    end

    def run(source)
        tokens = []
        scanner = Scanner.new(source)
        tokens += scanner.scan_tokens()
        # puts "TOKENS: #{tokens} #{tokens.class} size #{tokens.size}"
        parser = Parser.new(tokens)
        # puts "PARSER: #{parser} #{parser.class} tokens: #{parser.tokens}"
        expression = parser.parse()
        # puts "EXPRESSION: #{expression} #{expression.class}"
        # Stop if there was a syntax error.                   
        if (@had_error)
            return
        end
        puts "=> #{AstPrinter.new.print(expression)}"
        # scanner = Scanner.new(source)
        # tokens << scanner.scan_tokens()
        # tokens.each do |token| 
        #     puts token 
        # end
    end

    def self.error(line, message)
        raise ParseError.new(line, "", message)
    end
    
    # def self.report(line, where, message)
    #     "[line  #{line} ] Error #{where} : #{message}"
    #     had_error = true
    # end
end
