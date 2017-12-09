require 'matrix'
require './assert_helper.rb'

class Parser
  def initialize(lexer)
    @lexer = lexer
    @parsed = "// Parsed by povtoray (created by @urushiyama)\n"
    @pos = [0.0, 0.0, 0.0]
    @rotate = [0.0, 0.0, 0.0]
    @up = 1
    @right = 1
  end

  def parse
    begin
      parse_next()
      start()
    rescue => error
      STDERR.puts error.message
      @parsed = ""
    end
    return @parsed
  end

  def start
    @parsed << "SBT-raytracer 1.0\n"
    # set directional light template
    @parsed << "directional_light {\n"
    @parsed << "direction=( -0.764302,-0.392387,0.511737 );\n"
    @parsed << "color=( 1,1,1 );\n"
    @parsed << "}\n"
    while @token!=:EOD
      STDERR.print '.'
      case @token
      when :mesh
        mesh()
      when :camera
        camera()
      else
        parse_next()
      end
    end
  end

  def mesh
    assert(:mesh) {@parsed << "rotate(1, 0, 0, 4.71238898,\n" << "trimesh"}
    assert(:lbrace) {@parsed << "{\n"}
    # set material template
    @parsed << "material = {\n"
    @parsed << "diffuse = (0.8, 0.8, 0.8);\n"
    @parsed << "}\n"
    defines()
    assert(:rbrace) {@parsed << "}\n" << ");\n" }
  end

  def defines
    while @token==:vertex || @token==:face || @token==:other
      define()
    end
  end

  def define()
    case @token
    when :vertex
      assert(:vertex)
      assert(:lbrace)
      assert(:int)
      assert(:comma) {@parsed << "points = (\n"}
      vertexes()
      assert(:rbrace) {@parsed << ");\n"}
    when :face
      assert(:face)
      assert(:lbrace)
      assert(:int)
      assert(:comma) {@parsed << "faces = (\n"}
      faces()
      assert(:rbrace) {@parsed << ");\n"}
    when :other
      # unsupported defines
      assert(:other)
      assert(:lbrace)
      while @token!=:rbrace
        parse_next()
      end
      assert(:rbrace)
    else
      assert(:vertex, :face)
    end
  end

  def vertexes()
    vertex()
    while @token==:comma
      assert(:comma) {@parsed << ",\n"}
      vertex()
    end
    @parsed << "\n"
  end

  def vertex()
    assert(:langle) {@parsed << "("}
    assert(:real) {@parsed << @match}
    while @token==:comma
      assert(:comma) {@parsed << ","}
      assert(:real) {@parsed << @match}
    end
    assert(:rangle) {@parsed << ")"}
  end

  def faces()
    face()
    while @token==:comma
      assert(:comma) {@parsed << ",\n"}
      face()
    end
    @parsed << "\n"
  end

  def face()
    assert(:langle) {@parsed << "("}
    assert(:int) {@parsed << @match}
    while @token==:comma
      assert(:comma) {@parsed << ","}
      assert(:int) {@parsed << @match}
    end
    assert(:rangle) {@parsed << ")"}
  end

  def camera()
    assert(:camera) {@parsed << "camera"}
    assert(:lbrace) {@parsed << "{\n"}
    camera_params()
    assert(:rbrace) {@parsed << "}\n"}
  end

  def camera_params()
    while @token==:location || @token==:right || @token==:up || @token==:angle || @token==:rotate || @token==:translate ||@token==:look_at || @token==:other
      camera_param()
    end
    @parsed << "position = (#{@pos[0]},#{@pos[1]},#{@pos[1]});\n"
    rot = @rotate.map{|v| v * Math::PI / 180} # degree to radian
    viewdir_vector = Matrix[
      [Math.cos(rot[2]), -Math.sin(rot[2]), 0],
      [Math.sin(rot[2]), Math.cos(rot[2]), 0],
      [0, 0, 1]
    ] * Matrix[
      [Math.cos(rot[1]), 0, Math.sin(rot[1])],
      [0, 1, 0],
      [-Math.sin(rot[1]), 0, Math.cos(rot[1])]
    ] * Matrix[
      [1, 0, 0],
      [0, Math.cos(rot[0]), -Math.sin(rot[0])],
      [0, Math.sin(rot[0]), Math.cos(rot[0])]
    ] * Vector[0, 0, 1]
    @parsed << "viewdir = (#{viewdir_vector.to_a.join(',')});\n"
    updir_vector = Vector[0, 1, 0]
    @parsed << "updir = (#{updir_vector.to_a.join(',')});\n"
    @parsed << "aspectratio = #{@right / @up};\n"
  end

  def camera_param()
    case @token
    when :location
      assert(:location)
      assert(:langle)
      assert(:real, :int) {@pos[0] = @match.to_f} # X
      assert(:comma)
      assert(:real, :int) {@pos[2] = -@match.to_f} # -Z
      assert(:comma)
      assert(:real, :int) {@pos[1] = @match.to_f} # Y
      assert(:rangle)
    when :right
      assert(:right)
      assert(:langle)
      assert(:real, :int) {@right = @match.to_f.abs}
      assert(:comma)
      assert(:real, :int)
      assert(:comma)
      assert(:real, :int)
      assert(:rangle)
    when :up
      assert(:up)
      assert(:langle)
      assert(:real, :int)
      assert(:comma)
      assert(:real, :int) {@up = @match.to_f.abs}
      assert(:comma)
      assert(:real, :int)
      assert(:rangle)
    when :angle
      assert(:angle)
      assert(:real, :int) {@parsed << "fov = #{@match.to_f};\n"} # fov
    when :rotate
      assert(:rotate)
      assert(:langle)
      assert(:real, :int) {@rotate[0] = @match.to_f} # X rotate degree
      assert(:comma)
      assert(:real, :int) {@rotate[2] = -@match.to_f} # -Z rotate degree
      assert(:comma)
      assert(:real, :int) {@rotate[1] = @match.to_f} # Y rotate degree
      assert(:rangle)
    when :translate
      assert(:translate)
      assert(:langle)
      assert(:real, :int) {@pos[0] = @pos[0].to_f + @match.to_f} # X pos translate
      assert(:comma)
      assert(:real, :int) {@pos[2] = @pos[2].to_f - @match.to_f} # -Z pos translate
      assert(:comma)
      assert(:real, :int) {@pos[1] = @pos[1].to_f + @match.to_f} # Y pos translate
      assert(:rangle)
    when :look_at
      look_at = [0, 0, 0]
      assert(:look_at)
      assert(:langle)
      assert(:real, :int) {look_at[0] = @match.to_f} # X look_at
      assert(:comma)
      assert(:real, :int) {look_at[2] = -@match.to_f} # -Z look_at
      assert(:comma)
      assert(:real, :int) {look_at[1] = @match.to_f} # Y look_at
      assert(:rangle) {@parsed << "look_at = (#{look_at.join(',')});\n"}
    when :other
      # direction, sky, apertureなどのフォーカル・ブラーは未実装
      assert(:other)
      case @token
      when :langle
        vector()
      when :real
        assert(:real)
      when :int
        assert(:int)
      else
        assert(:langle, :real)
      end
    else
      assert(:location, :right, :up, :angle, :rotate, :translate, :look_at, :other)
    end
  end

  def vector()
    # 値の読み取りは不要とする
    assert(:langle)
    assert(:real, :int)
    while @token==:comma
      assert(:comma)
      assert(:real, :int)
    end
    assert(:rangle)
  end

  def assert(*tokens, &block)
    AssertHelper.assert('assert tokens') do
      tokens.include?(@token)
    end
    .then { block.call unless block.nil? }
    .catch do
      raise "Parse Error: unexpected #{@token}(#{@match}): #{tokens.join(' or ')} is expected"
    end
    .finally { parse_next() }
    .execute
  end

  def parse_next
    @lexer.lex do |token, match|
      @token = token
      @match = match
    end
  end
end
