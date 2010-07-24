
require 'todeb/base16'


module ToDeb
module Archive
  INFO = { '.tar'      => { :names => %w| |,
                            :extract => %w| tar --extract --file |,
                            :description => 'Uncompressed Tar archives.' },
           '.tar.lzma' => { :names => %w| |,
                            :extract => %w| tar --lzma --extract --file |,
                            :description => 'LZMA compressed Tar archives.' },
           '.tar.bz2'  => { :names => %w| .tbz |,
                            :extract => %w| tar --bzip2 --extract --file |,
                            :description => 'BZip2 compressed Tar archives.' },
           '.tar.gz'   => { :names => %w| .tgz |,
                            :extract => %w| tar --lzma --extract --file |,
                            :description => 'GZip compressed Tar archives.' } }
  NAMES = INFO.inject({}) do |acc, pair|
    canonical, stuff = pair
    acc[canonical] = [canonical] + stuff[:names]
    acc
  end
  DESCRIPTIONS = INFO.inject({}) do |acc, pair|
    canonical, stuff = pair
    acc[canonical] = stuff[:description]
    acc
  end
  EXTRACT = INFO.inject({}) do |acc, pair|
    canonical, stuff = pair
    acc[canonical] = stuff[:extract]
    acc
  end
extend self
  def supported_archives_statement
    DESCRIPTIONS.map do |canonical, description|
      sprintf '%-18s  %s', NAMES[canonical].join(', '), description
    end
  end
  def type(files_map)
    TYPES.select do |canonical, variants|
      ([canonical] + variants).any?{|name| files_map.key? name }
    end.first.first
  end
  def unpack_to_orig_dir(files_map, name)
    # Doin' it right here, in the present directory!
    orig = "#{name}.orig"
    type = Archive.type(files_map)
    working = File.expand_path('todeb_contents')
    archive = File.expand_path("todeb_archive#{type}")
    Dir.mkdir(orig)
    Dir.mkdir(working)
    # Decode archive onto filesystem.
    File.open(archive, File::CREAT|File::WRONLY) do |handle|
      content = StringIO.new(files_map[type])
      Base16::Decoder.new(:in => content, :out => handle).call
    end
    # Unpack archive and move contents in to `.orig' directory.
    Dir.chdir working do
      system *(EXTRACT[type] + [archive])
      if files_map['root']
        root = Dir[files_map['root']].first
        Dir.chdir root
      end
      Dir.open('.').foreach do |path|
        system *['mv', thing, orig] unless %w| . .. |.any?{|p| p == path }
      end
    end
  end
end
end

