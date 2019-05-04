class Environment
    attr_reader :values

    def initialize(enclosing = nil)
        @enclosing = enclosing
        @values = {}
    end

    def get(name)
        if @values.has_key? name.lexeme
            return @values[name.lexeme]
        end
        if @enclosing != nil
            return @enclosing.get(name)
        end
            raise "#{name}, Undefined variable: '#{name.lexeme}'."
    end

    def assign(name, value)
        if @values.has_key? name.lexeme
            @values[name.lexeme] = value
            return
        end
        if (@enclosing != nil)
            return @enclosing.assign(name, value)
        end
        throw "#{name}, Undefined variable: #{name.lexeme}."
    end

    def define(name, value)
        @values = { name => value } 
    end
end