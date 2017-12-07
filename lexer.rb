class Lexer
  def initialize(text)
    @remain = text.gsub(/(\r\n|\r|\n)/, " \n")
    @match = ""
    @token = nil
  end

  def lex
    while true
      if @remain.empty?
        @token = :EOD
        @match = ""
        yield @token, @match
        break
      end
      index = @remain.index("\n")
      if index.nil?
        remain_top = @remain
        remain_last = nil
      else
        remain_top = @remain[0, index+1]
        remain_last = @remain[index+1, @remain.length]
      end
      case remain_top
      when /^mesh2/
        @token = :mesh
        @match = $&
        @remain = $'
        @remain << remain_last unless remain_last.nil?
        yield @token, @match
        break
      when /^vertex_vectors/
        @token = :vertex
        @match = $&
        @remain = $'
        @remain << remain_last unless remain_last.nil?
        yield @token, @match
        break
      when /^face_indices/
        @token = :face
        @match = $&
        @remain = $'
        @remain << remain_last unless remain_last.nil?
        yield @token, @match
        break
      when /^camera/
        @token = :camera
        @match = $&
        @remain = $'
        @remain << remain_last unless remain_last.nil?
        yield @token, @match
        break
      when /^location/
        @token = :location
        @match = $&
        @remain = $'
        @remain << remain_last unless remain_last.nil?
        yield @token, @match
        break
      when /^right/
        @token = :right
        @match = $&
        @remain = $'
        @remain << remain_last unless remain_last.nil?
        yield @token, @match
        break
      when /^up/
        @token = :up
        @match = $&
        @remain = $'
        @remain << remain_last unless remain_last.nil?
        yield @token, @match
        break
      when /^angle/
        @token = :angle
        @match = $&
        @remain = $'
        @remain << remain_last unless remain_last.nil?
        yield @token, @match
        break
      when /^look_at/
        @token = :look_at
        @match = $&
        @remain = $'
        @remain << remain_last unless remain_last.nil?
        yield @token, @match
        break
      when /^rotate/
        @token = :rotate
        @match = $&
        @remain = $'
        @remain << remain_last unless remain_last.nil?
        yield @token, @match
        break
      when /^translate/
        @token = :translate
        @match = $&
        @remain = $'
        @remain << remain_last unless remain_last.nil?
        yield @token, @match
        break
      when /^\{/
        @token = :lbrace
        @match = $&
        @remain = $'
        @remain << remain_last unless remain_last.nil?
        yield @token, @match
        break
      when /^\}/
        @token = :rbrace
        @match = $&
        @remain = $'
        @remain << remain_last unless remain_last.nil?
        yield @token, @match
        break
      when /^</
        @token = :langle
        @match = $&
        @remain = $'
        @remain << remain_last unless remain_last.nil?
        yield @token, @match
        break
      when /^>/
        @token = :rangle
        @match = $&
        @remain = $'
        @remain << remain_last unless remain_last.nil?
        yield @token, @match
        break
      when /^,/
        @token = :comma
        @match = $&
        @remain = $'
        @remain << remain_last unless remain_last.nil?
        yield @token, @match
        break
      when /^-?[0-9]+\.[0-9]+/
        @token = :real
        @match = $&
        @remain = $'
        @remain << remain_last unless remain_last.nil?
        yield @token, @match
        break
      when /^-?[0-9]+/
        @token = :int
        @match = $&
        @remain = $'
        @remain << remain_last unless remain_last.nil?
        yield @token, @match
        break
      when /^\/\/[^\n]*/
        @token = :comment
        @match = $&
        @remain = $'
        @remain << remain_last unless remain_last.nil?
        yield @token, @match
        break
      when /^\s+/
        @token = :space
        @match = $&
        @remain = $'
        @remain << remain_last unless remain_last.nil?
        next
      when /^\S+/
        # 一致しないパターン
        @token = :other
        @match = $&
        @remain = $'
        @remain << remain_last unless remain_last.nil?
        yield @token, @match
        break
      end
    end
  end
end
