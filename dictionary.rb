class Dictionary
  def initialize
    @dict = {}
  end

  def write(name, type, data)
    if @dict[name].nil?
      @dict[name] = {type: type, data: data}
      return true
    else
      return false
    end
  end

  def read(name)
    return @dict[name]
  end
end
