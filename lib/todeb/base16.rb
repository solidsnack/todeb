
module ToDeb
module Base16

class Encoder
  attr_reader :in, :out, :format, :width, :indent
  def initialize(opts={})
    @in = (opts[:in] or STDIN)
    @out = (opts[:out] or STDOUT)
    @format = case opts[:case]
              when :lower then '%02x'
              when :upper then '%02X'
              else             '%02x'
              end
    @width = (opts[:width] or 64)
    @indent = case opts[:indent]
              when Integer then ' ' * opts[:indent]
              else              '  '
              end
  end
  def call
    buffer = ""
    @in.each_byte do |b|
      buffer << sprintf(@format, b)
      buffer = flush_one_line(buffer) unless buffer.length < @width
    end
    flush_one_line(buffer)
  end
private
  def flush_one_line(buffer)
    @out.puts(@indent + buffer[0...@width])
    buffer[@width..-1]
  end
end

class Decoder
  attr_reader :in, :out, :lower, :upper
  def initialize(opts={})
    @in = (opts[:in] or STDIN)
    @out = (opts[:out] or STDOUT)
    case opts[:case]
    when :upper then @lower, @upper = [false, true]
    when :both  then @lower, @upper = [true, true]
    when :lower then @lower, @upper = [true, false]
    else             @lower, @upper = [true, false]
    end
  end
  def call
    pair = []
    @in.each_byte do |b|
      val = case
            when "0123456789".index(b)
              "0123456789".index(b)
            when "abcdef".index(b)
              raise CaseError unless @lower
              10 + "abcdef".index(b)
            when "ABCDEF".index(b)
              raise CaseError unless @upper
              10 + "ABCDEF".index(b)
            when " \t\n".index(b)
              nil
            else
              raise InvalidChar
            end
      pair << val if val
      write_pair(pair) if 2 == pair.length
    end
    raise ContentTooShort unless 0 == pair.length or 2 == pair.length
    write_pair(pair) unless 0 == pair.length
  end
private
  def write_pair(pair)
    value = (pair[0] * 16) + pair[1]
    @out.putc(value)
    pair.clear
  end
end

end
end

