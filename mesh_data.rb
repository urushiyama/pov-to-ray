require 'matrix'

class MeshData
  attr_accessor :vertexes, :faces, :matrix, :name

  @@DEFAULT_MATRIX = Matrix[[]]

  def initialize(v = [], f = [], m = @@DEFAULT_MATRIX, n = nil)
    @vertexes = v
    @faces = f
    @matrix = m
    @name = n
  end

  def apply_matrix
    new_vertexes = @vertexes.map {|vector| @matrix * vector}
    return MeshData.new(new_vertexes, @faces, @@DEFAULT_MATRIX, @name)
  end

  def parse
    parsed = "trimesh {\n"
    parsed << "name=\"#{@name}\";\n" unless @name.nil?
    parsed << "material = {\n"
    parsed << "diffuse = (0.8, 0.8, 0.8);\n"
    parsed << "}\n"
    unless @vertexes.empty?
      parsed << "points = (\n"
      vertex = @vertexes.shift
      parsed << "(#{vertex[0]}, #{-vertex[2]}, #{vertex[1]})"
      until @vertexes.empty?
        parsed << ",\n"
        vertex = @vertexes.shift
        parsed << "(#{vertex[0]}, #{-vertex[2]}, #{vertex[1]})"
      end
      parsed << "\n);\n"
    end
    unless @faces.empty?
      parsed << "faces = (\n"
      face = @faces.shift
      parsed << "(#{face[0]}, #{face[1]}, #{face[2]})"
      until @faces.empty?
        parsed << ",\n"
        face = @faces.shift
        parsed << "(#{face[0]}, #{face[1]}, #{face[2]})"
      end
      parsed << "\n);\n"
    end
    parsed << "}\n"
    return parsed
  end
end
