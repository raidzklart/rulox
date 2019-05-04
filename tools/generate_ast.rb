class GenerateAST
    def initialize(path, file)
        @path =  "#{path}/#{file}.rb"
        @file = File.open(@path, "w+")
    end
    def main
        if ARGV.length != 2
            raise "Usage: generate_ast <output directory><file name>"
            exit 1
        end
        
        output_dir = ARGV[0]
        if ARGV[1] == "Expr"
            type_descriptions = ["Assign   : name, value", 
                                "Binary   : left, operator, right", 
                                "Grouping : expression", 
                                "Literal  : value", 
                                "Unary    : operator, right", 
                                "Variable : name" ] 
            define_ast(output_dir, "Expr", type_descriptions)
        elsif ARGV[1] == "stmt"
            define_ast(output_dir, "Stmt", ["Block      : statements","Expression : expression", "Print: expression", "Var        : name, initializer"])
        else
            puts "No method for your filename"
        end
    end

    def define_ast(output_dir, base_name, types) 
            @file.puts("module " + base_name)
            define_visitor(base_name, types)
            @file.puts("  def accept(visitor)")
            @file.puts("    end")
            types.each do |type|                        
                class_name = type.split(":")[0].strip        
                fields = type.split(":")[1].strip 
                define_type(base_name, class_name, fields)
            end
            @file.puts("    def accept(visitor)")
            @file.puts("    end")
            @file.puts("end")
    end

    def define_visitor(base_name, types)
        @file.puts("class Visitor")
        types.each do |type|
            type_name = type.split(":")[0].strip              
            @file.puts("    def visit_" + type_name.downcase + "_" + base_name.downcase + "(" + base_name.downcase + ")")
            @file.puts("    end")
        end
        @file.puts ("end")
    end

    def define_type(base_name, class_name, field_list)
        @file.puts("  class " + class_name)
        @file.puts("    include " + base_name)
        fields = field_list.split(", ")
        fields.each do |field|
            name = field.split(" ")                         
            @file.puts("     attr_reader :#{name.join}")
        end
        #Constructor.                                              
        @file.puts("    " + "def initialize"+ "(" + field_list + ")")
    
        #Store parameters in fields.
        fields.each do |field|                               
            name = field.split(" ")                         
            @file.puts("      @#{name.join} = #{name.join}")
        end
        @file.puts("    end")
        @file.puts("    def accept(visitor)")
        @file.puts("        return visitor.visit_" + class_name.downcase + "_" + base_name.downcase + "(self)")
        @file.puts("    end")
        @file.puts("  end")
    end
end
main = GenerateAST.new(ARGV[0], ARGV[1])
main.main