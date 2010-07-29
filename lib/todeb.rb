
require 'fileutils'

require 'todeb/archive'
require 'todeb/control_file'
require 'todeb/copyright_file'

module ToDeb

WORKING = 'todeb-working-dir'

class BasicFS
  attr_reader :spec, :debian_name
  def initialize(the_yaml)
    @spec = the_yaml
    @debian_name = "#{@spec['name']}_#{@spec['version']}"
    @root = "#{WORKING}/#{@debian_name}"
    @DEBIAN = "#{@root}/DEBIAN"
    @docs = "#{@root}/usr/share/doc/#{@spec['name']}"
  end
  def produce_deb_binary_directory
    File.directory? WORKING or Dir.mkdir WORKING
    Dir.chdir WORKING do
      Archive.unpack(@spec['filesystem'], @debian_name)
    end
  end
  def create_DEBIAN_directory
    FileUtils.mkdir_p @DEBIAN
  end
  def create_doc_directory
    FileUtils.mkdir_p @docs
  end
  def write_control_file
    STDERR.puts "Writing control file."
    control = ControlFile.from_yaml(@spec)
    File.open("#{@DEBIAN}/control", File::CREAT|File::WRONLY) do |h|
      h.puts(control.display)
    end
  end
  def write_copyright_file
    STDERR.puts "Writing copyright file."
    copyright = CopyrightFile.from_yaml(@spec)
    File.open("#{@docs}/copyright", File::CREAT|File::WRONLY) do |h|
      h.puts(copyright.display)
    end
  end
  def write_MD5_file
    Dir.chdir(@root) do
      cmd = %w[ find . -type f ! -regex '\./DEBIAN/.*' -printf '%P\0'
               | xargs -r0 md5sum
               > DEBIAN/md5sums ]
      system(cmd.join(' '))
    end
  end
  def run_deb
    STDERR.puts "Running `dpkg-deb'."
    Dir.chdir(WORKING) do
      system *(%w| fakeroot dpkg-deb --build | + [@debian_name])
    end
  end
private
  def archive_type
    Archive.type(@spec['filesystem'])
  end
end

end

