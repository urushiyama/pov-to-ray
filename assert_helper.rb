# assert(description:string) { expression: (*args) => bool}.then{ }.catch{ }.finally{ }
class AssertHelper
  attr_reader :description, :successed
  attr_accessor :thenProc, :catchProc, :finallyProc

  def initialize(params)
    @description = params[:description]
    @expression = params[:expression]
    @thenProc = params[:then]
    @catchProc = params[:catch]
    @finallyProc = params[:finally]
    @successed = params[:successed] || false
    @error = nil
  end

  def self.assert(description, &expression)
    return self.new(description: description, expression: expression)
  end

  def then(&block)
    clone = self.clone
    clone.thenProc = block
    return clone
  end

  def catch(&block)
    clone = self.clone
    clone.catchProc = block
    return clone
  end

  def finally(&block)
    clone = self.clone
    clone.finallyProc = block
    return clone
  end

  def execute
    @successed = @expression.call
    begin
      if @successed
        @thenProc.call
      else
        @catchProc.call
      end
    rescue => ex
      @error = ex
    end
    @finallyProc.call
    raise @error if @error
  end
end
