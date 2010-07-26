
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
    NAMES.select do |_, variants|
      variants.any?{|name| files_map.key? name }
    end.first.first
  end
  def unpack(files_map, name)
    # Doin' it right here, in the present directory!
    type = Archive.type(files_map)
    target = File.expand_path(name)
    archive = File.expand_path("#{name}#{type}")
    source = File.expand_path("#{archive}.d")
    Dir.mkdir(target)
    Dir.mkdir(source)
    # Decode archive onto filesystem.
    File.open(archive, File::CREAT|File::WRONLY) do |handle|
      content = StringIO.new(files_map[type])
      Base16::Decoder.new(:in => content, :out => handle).call
    end
    # Unpack archive and move contents in to target directory.
    Dir.chdir source do
      system *(EXTRACT[type] + [archive])
      mv = lambda do
        Dir.foreach('.') do |path|
          system *['mv', path, target] unless %w| . .. |.index(path)
        end
      end
      if files_map['root']
        root = Dir[files_map['root']].first
        Dir.chdir(root, &mv)
      else
        mv.call
      end
    end
  end
end
end

