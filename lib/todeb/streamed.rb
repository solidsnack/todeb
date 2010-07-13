

module ToDeb
  module Streamed
    def streams(stuff={})
      @io = Streams.new(stuff)
      nil
    end
  end
  class Streams
    attr_accessor :i, :o, :e
    def initialize(streams={})
      @i = (streams[:i] or STDIN)
      @o = (streams[:o] or STDOUT)
      @e = (streams[:e] or STDERR)
    end
  end
end

