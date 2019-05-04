require "./lox"
lox = Lox.new

if ARGV.length > 1
    puts "Usage: rulox [script]"
elsif ARGV.length == 1
    lox.run_file(ARGV[0])
    exit(64)
else
    lox.run_prompt()
end