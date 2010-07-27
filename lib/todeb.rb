
require 'todeb/archive'
require 'todeb/control_file'

module ToDeb

WORKING = 'todeb-working-dir'
MAINTAINER_REGEX = /^ *([^<]+) +<([^<>@]+@[^<>@]+)> *$/

class BasicFS
  attr_reader :spec, :debian_name
  def initialize(the_yaml)
    @spec = the_yaml
    @debian_name = "#{@spec['name']}_#{@spec['version']}"
    @DEBIAN = "#{WORKING}/#{@debian_name}/DEBIAN"
  end
  def produce_deb_binary_directory
    File.directory? WORKING or Dir.mkdir WORKING
    Dir.chdir WORKING do
      Archive.unpack(@spec['filesystem'], @debian_name)
    end
  end
  def create_DEBIAN_directory
    Dir.mkdir @DEBIAN
  end
  def write_control_file
    STDERR.puts "Writing control file."
    control = ControlFile.from_yaml(@spec)
    File.open("#{@DEBIAN}/control", File::CREAT|File::WRONLY) do |h|
      h.puts(control.display)
    end
  end
  def run_deb
    STDERR.puts "Running `dpkg-deb'."
    Dir.chdir(WORKING) do
      system *(%w| dpkg-deb --build | + [@debian_name])
    end
  end
private
  def archive_type
    Archive.type(@spec['filesystem'])
  end
  def env_set
    @originals = %w| DEBFULLNAME DEBEMAIL PWD |.inject({}) do |acc, var|
      acc[var] = ENV[var] if ENV[var]
      acc
    end
    m = MAINTAINER_REGEX.match(@spec['maintainer'])
    if m
      ENV['DEBFULLNAME'] = m[1]
      ENV['DEBEMAIL'] = m[2]
    end
    ENV['PWD'] = Dir.pwd     ## We set the PWD because `dh_make' uses it.
  end
  def env_unset
    @originals.each do |var, val|
      ENV[var] = val
    end if @originals
  end
end

end

