#! /usr/bin/env ruby
require "./parser.rb"
require "./lexer.rb"

class Main
  def initialize(text, options = {})
    STDERR.puts "Creating Lexer..."
    @lexer = Lexer.new(text)
    STDERR.puts "Lexer Created."
    STDERR.puts "Creating Parser..."
    @parser = Parser.new(@lexer, options)
    STDERR.puts "Parser Created."
  end

  def run
    STDERR.print "Parsing..."
    puts @parser.parse
    STDERR.puts "Done!"
  end
end

if $0 == __FILE__
  options = {}
  if ARGV.length > 0
    ARGV.each do |arg|
      case arg
      when '--include-comments'
        options[:include_comments] = true
      when '-C'
        options[:include_comments] = true
      end
    end
  end
  input = STDIN.read
  Main.new(input, options).run
end
