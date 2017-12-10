require './lexer.rb'

token = :other
remain = STDIN.read

lexer = Lexer.new(remain)

lexer.lex do |t, m, r, l|
  token = t
  puts "Token: #{t}, match: #{m}, line: #{l}, remain: #{r}"
end

while token!=:EOD
  lexer.lex do |t, m, r, l|
    token = t
    puts "Token: #{t}, match: #{m}, line: #{l}, remain: #{r}"
  end
end
