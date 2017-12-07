class Parser
  def initialize(lexer)
    @lexer = lexer
    @parsed = ""
  end

  def parse
    parse_next()
    start()
    return @parsed
  end

  def start
    @parsed << "SBT-raytracer 1.0\n"
    while @token!=:EOD
      STDERR.print '.'
      case @token
      when :mesh
        mesh()
      else
        parse_next()
      end
    end
    puts
  end

  def mesh
    assert(:mesh)
    @parsed << "rotate(1, 0, 0, 4.71238898,\n"
    @parsed << "trimesh"
    assert(:lbrace)
    @parsed << "{\n"
    # set material template
    @parsed << "material = {\n"
    @parsed << "diffuse = (0.8, 0.8, 0.8);\n"
    @parsed << "}\n"
    defines()
    assert(:rbrace)
    @parsed << "}\n"
    @parsed << ");\n"
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
      assert(:comma)
      @parsed << "points = (\n"
      vertexes()
      assert(:rbrace)
      @parsed << ");\n"
    when :face
      assert(:face)
      assert(:lbrace)
      assert(:int)
      assert(:comma)
      @parsed << "faces = (\n"
      faces()
      assert(:rbrace)
      @parsed << ");\n"
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
      assert(:comma)
      @parsed << ",\n"
      vertex()
    end
    @parsed << "\n"
  end

  def vertex()
    assert(:langle)
    @parsed << "("
    @parsed << @match
    assert(:real)
    while @token==:comma
      assert(:comma)
      @parsed << ","
      @parsed << @match
      assert(:real)
    end
    assert(:rangle)
    @parsed << ")"
  end

  def faces()
    face()
    while @token==:comma
      assert(:comma)
      @parsed << ",\n"
      face()
    end
    @parsed << "\n"
  end

  def face()
    assert(:langle)
    @parsed << "("
    @parsed << @match
    assert(:int)
    while @token==:comma
      assert(:comma)
      @parsed << ","
      @parsed << @match
      assert(:int)
    end
    assert(:rangle)
    @parsed << ")"
  end

  def assert(*tokens)
    unless (tokens.include?(@token))
      STDERR.puts "Parse Error: unexpected #{@token}(#{@match}): #{tokens.join(' or ')} is expected"
    end
    parse_next()
  end

  def parse_next
    @lexer.lex do |token, match|
      @token = token
      @match = match
    end
  end
end
