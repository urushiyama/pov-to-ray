require 'matrix'

class LightData
  attr_accessor :color, :matrix, :name

  @@DEFAULT_MATRIX = Matrix[[1,0,0,0],[0,0,1,0],[0,-1,0,0]]

  def initialize(color = [0,0,0], matrix = @@DEFAULT_MATRIX, name = nil)
    @color = color
    @matrix = matrix
    @name = name
  end

  def apply_matrix
    # primitive light hasn't vector to apply matrix
    return self.clone
  end

  def parse
    return ""
  end
end

class AmbientLightData < LightData
  def parse
    parsed = "ambient_light {\n"
    parsed << "colour = (#{@color[0]},#{@color[1]},#{@color[2]});\n"
    parsed << "}\n"
    return parsed
  end
end

class PointLightData < LightData
  attr_accessor :position, :constant_atten, :linear_atten, :quadratic_atten

  def apply_matrix
    appliedLight = self.clone
    appliedLight.position = @matrix * @position
    appliedLight.matrix = @@DEFAULT_MATRIX
    return appliedLight
  end

  def parse
    parsed = "point_light {\n"
    parsed << "position = (#{@position[0]},#{-@position[2]},#{@position[1]});\n"
    parsed << "colour = (#{@color[0]},#{@color[1]},#{@color[2]});\n"
    parsed << "constant_attenuation_coeff = #{@constant_atten};\n"
    parsed << "linear_attenuation_coeff = #{@linear_atten};\n"
    parsed << "quadratic_attenuation_coeff = #{@quadratic_atten};\n"
    parsed << "}\n"
    return parsed
  end
end

class DirectionalLightData < LightData
  attr_accessor :direction

  def apply_matrix
    appliedLight = self.clone
    appliedLight.direction = @matrix * @direction
    appliedLight.matrix = @@DEFAULT_MATRIX
    return appliedLight
  end

  def parse
    parsed = "directional_light {\n"
    # direction is the inverse of point_at
    parsed << "direction = (#{-@direction[0]},#{@direction[2]},#{-@direction[1]});\n"
    parsed << "colour = (#{@color[0]},#{@color[1]},#{@color[2]});\n"
    parsed << "}\n"
    return parsed
  end
end
