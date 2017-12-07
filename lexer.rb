class Lexer
  MAX_CHECK_LENGTH = 16

  def initialize(text)
    @remain = text.gsub(/(\r\n|\r|\n)/, ' ')
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
      remain_top = @remain[0, MAX_CHECK_LENGTH]
      remain_last = @remain[MAX_CHECK_LENGTH, @remain.length]
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
