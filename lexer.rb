class Lexer
  def initialize(text)
    # @remain = text.gsub(/(\r\n|\r|\n)/, " \n")
    @lines = text.lines
    @remain = @lines.shift
    @line_number = 1
    @match = ""
    @token = nil
  end

  def lex
    while true
      if @remain.empty?
        if @lines.empty?
          @token = :EOD
          @match = ""
          yield @token, @match, @remain, @line_number
          break
        else
          @remain = @lines.shift
          @line_number += 1
        end
      end
      # index = @remain.index("\n")
      # if index.nil?
      #   remain_top = @remain
      #   remain_last = nil
      # else
      #   remain_top = @remain[0, index+1]
      #   remain_last = @remain[index+1, @remain.length]
      # end
      # case remain_top
      case @remain
      when /^object/
        @token = :object
        @match = $&
        @remain = $'
        # @remain << "\n" << remain_last unless remain_last.nil?
        yield @token, @match, @remain, @line_number
        break
      when /^#declare/
        @token = :declare
        @match = $&
        @remain = $'
        # @remain << "\n" << remain_last unless remain_last.nil?
        yield @token, @match, @remain, @line_number
        break
      when /^#version/
        @token = :version
        @match = $&
        @remain = $'
        # @remain << "\n" << remain_last unless remain_last.nil?
        yield @token, @match, @remain, @line_number
        break
      when /^#default/
        @token = :default
        @match = $&
        @remain = $'
        # @remain << "\n" << remain_last unless remain_last.nil?
        yield @token, @match, @remain, @line_number
        break
      when /^=/
        @token = :equal
        @match = $&
        @remain = $'
        # @remain << "\n" << remain_last unless remain_last.nil?
        yield @token, @match, @remain, @line_number
        break
      when /^matrix/
        @token = :matrix
        @match = $&
        @remain = $'
        # @remain << "\n" << remain_last unless remain_last.nil?
        yield @token, @match, @remain, @line_number
        break
      when /^mesh2/
        @token = :mesh
        @match = $&
        @remain = $'
        # @remain << "\n" << remain_last unless remain_last.nil?
        yield @token, @match, @remain, @line_number
        break
      when /^vertex_vectors/
        @token = :vertex
        @match = $&
        @remain = $'
        # @remain << "\n" << remain_last unless remain_last.nil?
        yield @token, @match, @remain, @line_number
        break
      when /^face_indices/
        @token = :face
        @match = $&
        @remain = $'
        # @remain << "\n" << remain_last unless remain_last.nil?
        yield @token, @match, @remain, @line_number
        break
      when /^camera/
        @token = :camera
        @match = $&
        @remain = $'
        # @remain << "\n" << remain_last unless remain_last.nil?
        yield @token, @match, @remain, @line_number
        break
      when /^location/
        @token = :location
        @match = $&
        @remain = $'
        # @remain << "\n" << remain_last unless remain_last.nil?
        yield @token, @match, @remain, @line_number
        break
      when /^right/
        @token = :right
        @match = $&
        @remain = $'
        # @remain << "\n" << remain_last unless remain_last.nil?
        yield @token, @match, @remain, @line_number
        break
      when /^up/
        @token = :up
        @match = $&
        @remain = $'
        # @remain << "\n" << remain_last unless remain_last.nil?
        yield @token, @match, @remain, @line_number
        break
      when /^angle/
        @token = :angle
        @match = $&
        @remain = $'
        # @remain << "\n" << remain_last unless remain_last.nil?
        yield @token, @match, @remain, @line_number
        break
      when /^look_at/
        @token = :look_at
        @match = $&
        @remain = $'
        # @remain << "\n" << remain_last unless remain_last.nil?
        yield @token, @match, @remain, @line_number
        break
      when /^rotate/
        @token = :rotate
        @match = $&
        @remain = $'
        # @remain << "\n" << remain_last unless remain_last.nil?
        yield @token, @match, @remain, @line_number
        break
      when /^translate/
        @token = :translate
        @match = $&
        @remain = $'
        # @remain << "\n" << remain_last unless remain_last.nil?
        yield @token, @match, @remain, @line_number
        break
      when /^\{/
        @token = :lbrace
        @match = $&
        @remain = $'
        # @remain << "\n" << remain_last unless remain_last.nil?
        yield @token, @match, @remain, @line_number
        break
      when /^\}/
        @token = :rbrace
        @match = $&
        @remain = $'
        # @remain << "\n" << remain_last unless remain_last.nil?
        yield @token, @match, @remain, @line_number
        break
      when /^</
        @token = :langle
        @match = $&
        @remain = $'
        # @remain << "\n" << remain_last unless remain_last.nil?
        yield @token, @match, @remain, @line_number
        break
      when /^>/
        @token = :rangle
        @match = $&
        @remain = $'
        # @remain << "\n" << remain_last unless remain_last.nil?
        yield @token, @match, @remain, @line_number
        break
      when /^\(/
        @token = :lparen
        @match = $&
        @remain = $'
        # @remain << "\n" << remain_last unless remain_last.nil?
        yield @token, @match, @remain, @line_number
        break
      when /^\)/
        @token = :rparen
        @match = $&
        @remain = $'
        # @remain << "\n" << remain_last unless remain_last.nil?
        yield @token, @match, @remain, @line_number
        break
      when /^,/
        @token = :comma
        @match = $&
        @remain = $'
        # @remain << "\n" << remain_last unless remain_last.nil?
        yield @token, @match, @remain, @line_number
        break
      when /^;/
        @token = :semicolon
        @match = $&
        @remain = $'
        # @remain << "\n" << remain_last unless remain_last.nil?
        yield @token, @match, @remain, @line_number
        break
      when /^-?[0-9]+\.[0-9]+/
        @token = :real
        @match = $&
        @remain = $'
        # @remain << "\n" << remain_last unless remain_last.nil?
        yield @token, @match, @remain, @line_number
        break
      when /^-?[0-9]+/
        @token = :int
        @match = $&
        @remain = $'
        # @remain << "\n" << remain_last unless remain_last.nil?
        yield @token, @match, @remain, @line_number
        break
      when /^\/\/[^\n]*/
        @token = :comment
        @match = $&
        @remain = $'
        # @remain << "\n" << remain_last unless remain_last.nil?
        yield @token, @match, @remain, @line_number
        break
      when /^[A-Za-z_][A-Za-z0-9_]*/
        @token = :identifier
        @match = $&
        @remain = $'
        # @remain << "\n" << remain_last unless remain_last.nil?
        yield @token, @match, @remain, @line_number
        break
      when /^\s+/
        @token = :space
        @match = $&
        @remain = $'
        # @remain << "\n" << remain_last unless remain_last.nil?
        next
      when /^\S+/
        @token = :other
        @match = $&
        @remain = $'
        # @remain << "\n" << remain_last unless remain_last.nil?
        yield @token, @match, @remain, @line_number
        break
      end
    end
  end
end
