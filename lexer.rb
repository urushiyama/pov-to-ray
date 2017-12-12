class Lexer
  def initialize(text)
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
      case @remain
      # --- Definitions ---
      when /^#version/
        @token = :version
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^#default/
        @token = :default
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^#declare/
        @token = :declare
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^=/
        @token = :equal
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      # --- Mesh data ---
      when /^object/
        @token = :object
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^mesh2/
        @token = :mesh
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^vertex_vectors/
        @token = :vertex
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^face_indices/
        @token = :face
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      # --- Light settings ---
      when /^light_source/
        @token = :light_source
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^color/
        @token = :color
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^srgb/
        @token = :srgb
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^fade_distance/
        @token = :fade_distance
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^fade_power/
        @token = :fade_power
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^parallel/
        @token = :parallel
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^shadowless/
        @token = :shadowless
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^point_at/
        @token = :point_at
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      # --- Camera settings ---
      when /^camera/
        @token = :camera
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^location/
        @token = :location
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^right/
        @token = :right
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^up/
        @token = :up
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^angle/
        @token = :angle
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^look_at/
        @token = :look_at
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      #  transform
      when /^rotate/
        @token = :rotate
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^translate/
        @token = :translate
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^matrix/
        @token = :matrix
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      # --- Dycks ---
      when /^\{/
        @token = :lbrace
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^\}/
        @token = :rbrace
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^</
        @token = :langle
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^>/
        @token = :rangle
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^\(/
        @token = :lparen
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^\)/
        @token = :rparen
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      # --- Numbers ---
      when /^-?[0-9]+\.[0-9]+/
        @token = :real
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^-?[0-9]+/
        @token = :int
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      # --- Comments ---
      when /^\/\/[^\n]*/
        @token = :comment
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      # --- Identifiers ---
      when /^[A-Za-z_][A-Za-z0-9_]*/
        @token = :identifier
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      # --- Separators ---
      when /^,/
        @token = :comma
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^;/
        @token = :semicolon
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^\s+/
        @token = :space
        @match = $&
        @remain = $'
        next
      # --- Others ---
      when /^\S+/
        @token = :other
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      end
    end
  end
end
