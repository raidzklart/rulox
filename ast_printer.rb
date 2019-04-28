require "./Expr"
require "./token"
require "./parser"
class AstPrinter
    include Expr
    def print(expr)
        begin
            return expr.accept(self)
        rescue => exception
            puts "AST Print Error: #{exception}"
        end                                          
    end
    
    def visit_binary_expr(expr)                  
        return parenthesize(expr.operator, [expr.left, expr.right])
    end
    
    def visit_grouping_expr(expr)              
        return parenthesize("group", expr.expression)                   
    end                                                                  
    
    def visit_literal_expr(expr)                
        if (expr.value == nil) 
            return "nil"
        end                        
        return expr.value.to_s                                  
    end                                                                  
    
    def visit_unary_expr(expr)                    
        return parenthesize(expr.operator, expr.right)          
    end
    
    def parenthesize(name, *exprs)
        builder = ""
        builder += "(#{name}"
        exprs.each do |expr, i|
                builder += " #{expr.accept(self)}"
                builder += " #{i.accept(self)}" unless i.nil?
        end
        builder += ")"                               
    
        return builder.to_s                            
    end
    
    def main()                 
        expression = Binary.new(                     
            Unary.new(                                    
                Token.new(:minus, "-", nil, 1),      
                Literal.new(123)),                        
                    Token.new(:star, "*", nil, 1),           
                    Grouping.new(Literal.new(45.67)))
    
        puts(AstPrinter.new.print(expression))
    end               
end
# printer = AstPrinter.new
# printer.main