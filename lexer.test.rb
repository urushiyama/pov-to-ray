require './lexer.rb'

token = nil
match = ""
remain = STDIN.read

lexer = Lexer.new(remain)

lexer.lex do |t, m|
  token = t
  match = m
  puts "Token: #{token}, match: #{match}"
end

while token!=:EOD
  lexer.lex do |t, m|
    token = t
    match = m
    puts "Token: #{token}, match: #{match}"
  end
end
