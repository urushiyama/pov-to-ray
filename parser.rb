require 'matrix'
require './assert_helper.rb'
require './dictionary.rb'
require './mesh_data.rb'

class Parser
  def initialize(lexer)
    @lexer = lexer
    @parsed = "// Parsed by povtoray (created by @urushiyama)\n"
    @pos = [0.0, 0.0, 0.0]
    @rotate = [0.0, 0.0, 0.0]
    @up = 1
    @right = 1
    @look_at = [0,0,-1]
    @fov = 50
    @dict = Dictionary.new
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
    @parsed << "direction=( -0.764302,-0.392387,-0.511737 );\n"
    @parsed << "color=( 1,1,1 );\n"
    @parsed << "}\n"
    @parsed << "directional_light {\n"
    @parsed << "direction=( 0.392387,0.764302,-0.511737 );\n"
    @parsed << "color=( 1,1,1 );\n"
    @parsed << "}\n"
    while @token!=:EOD
      STDERR.print '.'
      case @token
      when :declare
        declare()
      # when :mesh
      #   mesh()
      when :camera
        camera()
      when :object
        object()
      else
        parse_next()
      end
    end
  end

  def declare
    identifier = ""
    id_line = 0
    assert(:declare)
    assert(:identifier) do
      identifier = @match
      id_line = @line_number
    end
    assert(:equal)
    case @token
    when :int
      assert(:int) do
        unless @dict.write(identifier, :int, @match.to_i)
          STDERR.puts "Parse Error: #{identifier} in line #{id_line} is duplicated\n"
        end
      end
      assert(:semicolon)
    when :real
      assert(:real) do
        unless @dict.write(identifier, :real, @match.to_f)
          STDERR.puts "Parse Error: #{identifier} in line #{id_line} is duplicated\n"
        end
      end
      assert(:semicolon)
    when :langle
      vector()
      assert(:semicolon)
    when :mesh
      mesh() do |data|
        unless @dict.write(identifier, :mesh, data)
          STDERR.puts "Parse Error: #{identifier} in line #{id_line} is duplicated\n"
        end
      end
    when :identifier
      # assert(:identifier)
      define()
    else
      assert(:int, :real, :mesh, :identifier)
    end
  end

  def object
    assert(:object)
    assert(:lbrace)
    object_defines() do |mesh|
      @parsed << mesh.apply_matrix.parse unless mesh.nil?
    end
    assert(:rbrace)
  end

  def object_defines
    mesh = nil
    mesh_matrix = nil
    while @token==:identifier || @token==:matrix
      case @token
      when :identifier
        assert(:identifier) do
          data = @dict.read(@match)
          if data.nil? || data[:type].nil? || data[:type]!=:mesh
            # unsupported identifier or undeclared identifier
            while @token!=:identifier && @token!=:matrix && @token!=:rbrace
              parse_next()
              if @token==:EOD
                STDERR.puts "Parse Error: reached end of line before expected #{[:identifier, :matrix, :rbrace].join(' or ')} is appeared\n"
                break
              end
            end
          else
            mesh = data[:data]
            mesh.name = @match
          end
        end
      when :matrix
        matrix = [[0,0,0,0], [0,0,0,0], [0,0,0,0]]
        assert(:matrix)
        assert(:langle)
        assert(:int, :real) {matrix[0][0] = @match.to_f}
        assert(:comma)
        assert(:int, :real) {matrix[1][0] = @match.to_f}
        assert(:comma)
        assert(:int, :real) {matrix[2][0] = @match.to_f}
        assert(:comma)
        assert(:int, :real) {matrix[0][1] = @match.to_f}
        assert(:comma)
        assert(:int, :real) {matrix[1][1] = @match.to_f}
        assert(:comma)
        assert(:int, :real) {matrix[2][1] = @match.to_f}
        assert(:comma)
        assert(:int, :real) {matrix[0][2] = @match.to_f}
        assert(:comma)
        assert(:int, :real) {matrix[1][2] = @match.to_f}
        assert(:comma)
        assert(:int, :real) {matrix[2][2] = @match.to_f}
        assert(:comma)
        assert(:int, :real) {matrix[0][3] = @match.to_f}
        assert(:comma)
        assert(:int, :real) {matrix[1][3] = @match.to_f}
        assert(:comma)
        assert(:int, :real) {matrix[2][3] = @match.to_f}
        assert(:rangle) {mesh_matrix = Matrix[*matrix]}
      else
        assert(:identifier, :matrix)
      end
    end
    mesh.matrix = mesh_matrix unless mesh.nil?
    yield mesh
  end

  def mesh
    mesh = nil
    assert(:mesh)
    assert(:lbrace)
    defines() do |d|
      mesh = d
    end
    assert(:rbrace) {yield mesh}
  end

  def defines
    mesh = MeshData.new
    while @token==:vertex || @token==:face || @token==:declare || @token==:identifier
      define() do |t, d|
        case t
        when :vertex
          mesh.vertexes = d
        when :face
          mesh.faces = d
        end
      end
    end
    yield mesh
  end

  def define()
    case @token
    when :vertex
      assert(:vertex)
      assert(:lbrace)
      assert(:int)
      assert(:comma)
      vertexes() {|d| yield :vertex, d}
      assert(:rbrace)
    when :face
      assert(:face)
      assert(:lbrace)
      assert(:int)
      assert(:comma)
      faces() {|d| yield :face, d}
      assert(:rbrace)
    when :identifier
      # unsupported defines
      braces = []
      assert(:identifier)
      case @token
      when :lbrace
        # group { ... }
        assert(:lbrace) {braces.push({match: @match, line: @line_number})}
        until braces.empty?
          if @token==:rbrace
            braces.pop
          elsif @token==:lbrace
            braces.push({match: @match, line: @line_number})
          end
          parse_next()
        end
      when :lparen
        # func ( [:int || :real || :vector || :identifier] (, ...)* )
        assert(:lparen)
        func_params()
        while @token==:comma
          assert(:comma)
          func_params()
        end
        assert(:rparen)
      else
        assert(:lbrace, :lparen)
      end
    when :declare
      declare()
    else
      assert(:vertex, :face)
    end
  end

  def func_params()
    case @token
    when :int
      assert(:int)
    when :real
      assert(:real)
    when :langle
      vector()
    when :identifier
      assert(:identifier)
    else
      assert(:int, :real, :langle, :identifier)
    end
  end

  def vertexes()
    vertexes = []
    vertex() {|vertex| vertexes.push(vertex)}
    while @token==:comma
      assert(:comma)
      vertex() {|vertex| vertexes.push(vertex)}
    end
    yield vertexes
  end

  def vertex()
    vertex = Vector[0, 0, 0, 1]
    assert(:langle)
    assert(:int, :real) {vertex = Vector[@match.to_f, vertex[1], vertex[2], vertex[3]]}
    assert(:comma)
    assert(:int, :real) {vertex = Vector[vertex[0], @match.to_f, vertex[2], vertex[3]]}
    assert(:comma)
    assert(:int, :real) {vertex = Vector[vertex[0], vertex[1], @match.to_f, vertex[3]]}
    assert(:rangle) {yield vertex}
  end

  def faces()
    faces = []
    face() {|face| faces.push(face)}
    while @token==:comma
      assert(:comma)
      if @token==:int
        # texture-mapped faces
        assert(:int)
        assert(:comma)
        assert(:int)
        assert(:comma)
        assert(:int)
        break if @token!=:comma
        assert(:comma)
      end
      face() {|face| faces.push(face)}
    end
    yield faces
  end

  def face()
    face = [0,0,0]
    assert(:langle)
    assert(:int) {face[0] = @match.to_i}
    assert(:comma)
    assert(:int) {face[1] = @match.to_i}
    assert(:comma)
    assert(:int) {face[2] = @match.to_i}
    assert(:rangle) {yield face}
  end

  def camera()
    assert(:camera) {@parsed << "camera"}
    assert(:lbrace) {@parsed << "{\n"}
    camera_params()
    assert(:rbrace) {@parsed << "}\n"}
  end

  def camera_params()
    while @token==:location || @token==:right || @token==:up || @token==:angle || @token==:rotate || @token==:translate ||@token==:look_at || @token==:identifier
      camera_param()
    end
    @parsed << "position = (#{@pos[0]},#{@pos[1]},#{@pos[2]});\n"
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
    ] * Vector[*@look_at]
    @parsed << "viewdir = (#{viewdir_vector.to_a.join(',')});\n"
    # updir_vector = Vector[0, 0, 1]
    updir_vector = Matrix[
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
    ] * Vector[0, 1, 0]
    @parsed << "updir = (#{updir_vector.to_a.join(',')});\n"
    @parsed << "aspectratio = #{@right / @up};\n"
    @parsed << "fov = #{@fov / @right * @up};\n"
  end

  def camera_param()
    case @token
    when :location
      assert(:location)
      assert(:langle)
      assert(:real, :int) {@pos[0] = @match.to_f} # X
      assert(:comma)
      assert(:real, :int) {@pos[2] = @match.to_f} # -Z
      assert(:comma)
      assert(:real, :int) {@pos[1] = -@match.to_f} # Y
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
      assert(:real, :int) {@fov = @match.to_f} # fov
    when :rotate
      assert(:rotate)
      assert(:langle)
      assert(:real, :int) {@rotate[0] = -@match.to_f} # X rotate degree
      assert(:comma)
      assert(:real, :int) {@rotate[2] = @match.to_f} # -Z rotate degree
      assert(:comma)
      assert(:real, :int) {@rotate[1] = @match.to_f} # Y rotate degree
      assert(:rangle)
    when :translate
      assert(:translate)
      assert(:langle)
      assert(:real, :int) {@pos[0] = @pos[0].to_f + @match.to_f} # X pos translate
      assert(:comma)
      assert(:real, :int) {@pos[2] = @pos[2].to_f + @match.to_f} # -Z pos translate
      assert(:comma)
      assert(:real, :int) {@pos[1] = @pos[1].to_f - @match.to_f} # Y pos translate
      assert(:rangle)
    when :look_at
      assert(:look_at)
      assert(:langle)
      assert(:real, :int) {@look_at[0] = @match.to_f} # X look_at
      assert(:comma)
      assert(:real, :int) {@look_at[1] = @match.to_f} # Y look_at
      assert(:comma)
      assert(:real, :int) {@look_at[2] = @match.to_f} # Z look_at
      assert(:rangle) # {@parsed << "look_at = (#{look_at.join(',')});\n"}
    when :identifier
      # direction, sky, apertureなどのフォーカル・ブラーは未実装
      assert(:identifier)
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
      assert(:location, :right, :up, :angle, :rotate, :translate, :look_at, :identifier)
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
      massage = "\n#{@line_number}: #{@match + @remain.chomp}\n"+ " " * (@line_number.to_s.length) +"  ^"+"~"*(@match.length - 1)
      massage << "\nParse Error: unexpected #{@token} in line #{@line_number}: #{tokens.join(' or ')} is expected"
      raise massage
    end
    .finally { parse_next() }
    .execute
  end

  def parse_next
    @lexer.lex do |t, m, r, l|
      @token = t
      @match = m
      @remain = r
      @line_number = l
    end
  end
end
