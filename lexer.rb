class Lexer
  attr_reader :line_count

  def initialize(text)
    @lines = text.lines
    @line_count = @lines.length
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
      when /^normal_vectors/
        @token = :identifier
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^normal_indices/
        @token = :identifier
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      # --- Global settings ---
      when /^global_settings/
        @token = :global_settings
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^assumed_gamma/
        @token = :assumed_gamma
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^ambient_light/
        @token = :ambient_light
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^charset/
        @token = :charset
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^ascii/
        @token = :ascii
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^utf8/
        @token = :utf8
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^sys/
        @token = :sys
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^hf_gray_16/
        @token = :hf_gray_16
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
      when /^srgbf/
        @token = :srgbf
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^srgbt/
        @token = :srgbt
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^srgbft/
        @token = :srgbft
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^rgb/
        @token = :rgb
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^rgbf/
        @token = :rgbf
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^rgbt/
        @token = :rgbt
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^rgbft/
        @token = :rgbft
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
      # Not implemented yet...
      when /^media_attenuation/
        @token = :media_attenuation
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^media_interaction/
        @token = :media_interaction
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^spotlight/
        @token = :spotlight
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^cylinder/
        @token = :cylinder
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^area_light/
        @token = :area_light
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^adaptive/
        @token = :adaptive
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^jitter/
        @token = :jitter
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^circular/
        @token = :circular
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^orient/
        @token = :orient
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
      # --- Booleans ---
      when /^(on|yes|true)/
        @token = :true
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^(off|no|false)/
        @token = :false
        @match = $&
        @remain = $'
        yield @token, @match, @remain, @line_number
        break
      when /^yes/
        @token = :true
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
