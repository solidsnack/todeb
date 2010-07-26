
require 'todeb/archive'

module ToDeb

WORKING = 'todeb-working-dir'
MAINTAINER_REGEX = /^ *([^<]+) +<([^<>@]+@[^<>@]+)> *$/

class BasicArchive
  attr_reader :spec, :debian_name
  def initialize(the_yaml)
    @spec = the_yaml
    @debian_name = "#{@spec['name']}_#{@spec['version']}"
  end
  def produce_deb_binary_directory
    File.directory? WORKING or Dir.mkdir WORKING
    Dir.chdir WORKING do
      Archive.unpack(@spec['filesystem'], @debian_name)
    end
  end
  def create_DEBIAN_directory
    Dir.mkdir "#{WORKING}/#{@debian_name}/DEBIAN"
  end
  def write_control_file
  end
  def write_rules_file
  end
  def run_deb
    STDERR.puts "Running `dpkg-deb'."
    Dir.chdir("#{WORKING}/#{@dh_make_name}") do
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

