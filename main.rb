#! /usr/bin/env ruby
require "./parser.rb"
require "./lexer.rb"

class Main
  def initialize(text)
    STDERR.puts "Creating Lexer..."
    @lexer = Lexer.new(text)
    STDERR.puts "Lexer Created."
    STDERR.puts "Creating Parser..."
    @parser = Parser.new(@lexer)
    STDERR.puts "Parser Created."
  end

  def run
    STDERR.print "Parsing..."
    puts @parser.parse
    STDERR.puts "Done!"
  end
end

input = STDIN.read
Main.new(input).run
