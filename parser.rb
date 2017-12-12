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
    STDERR.print "["
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
      case @token
      when :declare
        declare()
      when :camera
        camera()
      when :light_source
        light_source()
      when :object
        object()
      else
        parse_next()
      end
    end
    STDERR.print "]\n"
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
        matrix() {|mat| mesh_matrix = Matrix[*mat]}
      else
        assert(:identifier, :matrix)
      end
    end
    mesh.matrix = mesh_matrix unless mesh.nil?
    yield mesh
  end

  def matrix(&block)
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
    assert(:rangle) {block.call(matrix) unless block.nil?}
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
      assert(:identifier)
      case @token
      when :lbrace
        group()
      when :lparen
        func_params()
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
    # func ( [:int || :real || :vector || :identifier] (, ...)* )
    assert(:lparen)
    func_param()
    while @token==:comma
      assert(:comma)
      func_param()
    end
    assert(:rparen)
  end

  def func_param()
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

  def group()
    # group { ... }
    braces = []
    assert(:lbrace) {braces.push({match: @match, line: @line_number})}
    until braces.empty?
      if @token==:rbrace
        braces.pop
      elsif @token==:lbrace
        braces.push({match: @match, line: @line_number})
      end
      parse_next()
    end
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
      assert(:rangle)
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
        assert(:langle, :real, :int)
      end
    else
      assert(:location, :right, :up, :angle, :rotate, :translate, :look_at, :identifier)
    end
  end

  def light_source()
    assert(:light_source)
    assert(:lbrace)
    light_definitions()
    assert(:rbrace)
  end

  def light_definitions()
    accepts = [
      :langle, :color,
      :spotlight, :cylinder, :parallel, :area_light,
      :shadowless, :fade_distance, :fade_power,
      :media_attenuation, :media_interaction, :matrix, :identifier
    ]
    while accepts.include?(@token)
      case @token
      when :langle
        # light location before applying matrix
        assert(:langle)
        assert(:int, :real)
        assert(:comma)
        assert(:int, :real)
        assert(:comma)
        assert(:int, :real)
        assert(:rangle)
      when :color
        assert(:color)
        color_statements()
      when :spotlight
        assert(:spotlight)
        spotlight_definitions()
      when :cylinder
        assert(:cylinder)
        cylinder_light_definitions()
      when :parallel
        assert(:parallel)
        parallel_light_definitions()
      when :area_light
        assert(:area_light)
        area_light_definitions()
      when :shadowless
        assert(:shadowless) # still make shadow
      when :fade_distance
        assert(:fade_distance)
        assert(:int, :real)
      when :fade_power
        assert(:fade_power)
        assert(:int, :real) # cast to 0, 1 or 2
      when :media_attenuation
        assert(:media_attenuation)
        assert(:on, :off)
      when :media_interaction
        assert(:media_interaction)
        assert(:on, :off)
      when :matrix
        matrix()
      when :identifier
        # looks_like, project_through, light_groupは未実装
        assert(:identifier)
        group()
      else
        assert(*accepts)
      end
    end
  end

  def spotlight_definitions()
    while @token==:point_at || @token==:identifier
      case @token
      when :point_at
        assert(:point_at)
        assert(:langle)
        assert(:int, :real)
        assert(:comma)
        assert(:int, :real)
        assert(:comma)
        assert(:int, :real)
        assert(:rangle)
      when :identifier
        # radius, falloff, tightness (, looks_like, project_through, light_group)
        assert(:identifier)
        case @token
        when :int
          assert(:int)
        when :real
          assert(:real)
        when :lbrace
          group()
        else
          assert(:int, :real, :lbrace)
        end
      end
    end
  end

  def cylinder_light_definitions()
    while @token==:point_at || @token==:identifier
      case @token
      when :point_at
        assert(:point_at)
        assert(:langle)
        assert(:int, :real)
        assert(:comma)
        assert(:int, :real)
        assert(:comma)
        assert(:int, :real)
        assert(:rangle)
      when :identifier
        # radius, falloff, tightness (, looks_like, project_through, light_group)
        assert(:identifier)
        case @token
        when :int
          assert(:int)
        when :real
          assert(:real)
        when :lbrace
          group()
        else
          assert(:int, :real, :lbrace)
        end
      end
    end
  end

  def parallel_light_definitions()
    assert(:point_at)
    assert(:langle)
    assert(:int, :real)
    assert(:comma)
    assert(:int, :real)
    assert(:comma)
    assert(:int, :real)
    assert(:rangle)
  end

  def area_light_definitions()
    vector() # <AXIS 1>
    assert(:comma)
    vector() # <AXIS 2>
    assert(:comma)
    assert(:int, :real) # SIZE 1
    assert(:comma)
    assert(:int, :real) # SIZE 2
    accepts = [:adaptive, :jitter, :circular, :orient, :spotlight, :cylinder]
    while accepts.include?(@token)
      case @token
      when :adaptive
        assert(:adaptive)
        assert(:int)
      when :jitter
        assert(:jitter)
      when :circular
        assert(:circular)
      when :orient
        assert(:orient)
      when :spotlight
        assert(:spotlight)
        spotlight_definitions()
      when :cylinder
        assert(:cylinder)
        cylinder_light_definitions()
      else
        assert(*accepts)
      end
    end
  end

  def color_statements()
    case @token
    when :rgb
      rgb()
    when :rgbf
      rgbf()
    when :rgbt
      rgbt()
    when :rgbft
      rgbft()
    when :srgb
      srgb()
    when :srgbf
      srgbf()
    when :srgbt
      srgbt()
    when :srgbft
      srgbft()
    else
      assert(:rgb, :rgbf, :rgbt, :rgbft, :srgb, :srgbf, :srgbt, :srgbft)
    end
  end

  def rgb()
    assert(:rgb)
    assert(:langle)
    assert(:int, :real)
    assert(:comma)
    assert(:int, :real)
    assert(:comma)
    assert(:int, :real)
    assert(:rangle)
  end

  def rgbf()
    assert(:rgbf)
    assert(:langle)
    assert(:int, :real)
    assert(:comma)
    assert(:int, :real)
    assert(:comma)
    assert(:int, :real)
    assert(:comma)
    assert(:int, :real)
    assert(:rangle)
  end

  def rgbt()
    assert(:rgbt)
    assert(:langle)
    assert(:int, :real)
    assert(:comma)
    assert(:int, :real)
    assert(:comma)
    assert(:int, :real)
    assert(:comma)
    assert(:int, :real)
    assert(:rangle)
  end

  def rgbft()
    assert(:rgbft)
    assert(:langle)
    assert(:int, :real)
    assert(:comma)
    assert(:int, :real)
    assert(:comma)
    assert(:int, :real)
    assert(:comma)
    assert(:int, :real)
    assert(:comma)
    assert(:int, :real)
    assert(:rangle)
  end

  def srgb()
    assert(:srgb)
    assert(:langle)
    assert(:int, :real)
    assert(:comma)
    assert(:int, :real)
    assert(:comma)
    assert(:int, :real)
    assert(:rangle)
  end

  def srgbf()
    assert(:srgbf)
    assert(:langle)
    assert(:int, :real)
    assert(:comma)
    assert(:int, :real)
    assert(:comma)
    assert(:int, :real)
    assert(:comma)
    assert(:int, :real)
    assert(:rangle)
  end

  def srgbt()
    assert(:srgbt)
    assert(:langle)
    assert(:int, :real)
    assert(:comma)
    assert(:int, :real)
    assert(:comma)
    assert(:int, :real)
    assert(:comma)
    assert(:int, :real)
    assert(:rangle)
  end

  def srgbft()
    assert(:srgbft)
    assert(:langle)
    assert(:int, :real)
    assert(:comma)
    assert(:int, :real)
    assert(:comma)
    assert(:int, :real)
    assert(:comma)
    assert(:int, :real)
    assert(:comma)
    assert(:int, :real)
    assert(:rangle)
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
    @parse_ratio ||= 0
    new_parse_ratio = @line_number.to_f / @lexer.line_count
    if (new_parse_ratio * 10).to_i > (@parse_ratio * 10).to_i
      STDERR.print '#'
      @parse_ratio = new_parse_ratio
    end
  end
end
