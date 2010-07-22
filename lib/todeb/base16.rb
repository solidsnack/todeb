
module ToDeb
class Base16
  def initialize(opts={})
    @in = (opts[:in] or STDIN)
    @out = (opts[:out] or STDOUT)
    @format = case opts[:case]
              when :lower then '%02x'
              when :upper then '%02X'
              else             '%02x'
              end
    @width = (opts[:width] or 64)
    @indent = case opts[:pad]
              when Integer then ' ' * opts[:pad]
              else              '  '
              end
  end
  def encode
    buffer = ""
    @in.each_byte do |b|
      buffer << sprintf(@format, b)
      buffer = flush_one_line(buffer) unless buffer.length < @width
    end
    flush_one_line(buffer)
  end
  def decode
  end
private
  def flush_one_line(buffer)
    @out.puts(@indent + buffer[0...@width])
    buffer[@width..-1]
  end
end
end

