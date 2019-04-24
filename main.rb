require "./lox"

if ARGV.length > 1
    puts "Usage: jlox [script]"
elsif ARGV.length == 1
    exit(64)
else
    lox = Lox.new
    lox.run_prompt()
end