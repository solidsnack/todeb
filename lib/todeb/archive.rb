
module ToDeb
module Archive
  TYPES = { '.tar.lzma' => %w| |,
            '.tar.bz2' => %w| .tbz |,
            '.tar.gz' => %w| .tgz | }
extend self
  def supported_archives_statement
    TYPES.map do |canonical, variants|
      [ canonical,
        "(also #{variants.join(', ')})" unless variants.empty?
      ].compact.join(' ')
    end
  end
  def type(files_map)
    TYPES.select do |canonical, variants|
      ([canonical] + variants).any?{|name| files_map.key? name }
    end.first.first
  end
end
end

