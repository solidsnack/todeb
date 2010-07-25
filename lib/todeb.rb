
require 'todeb/archive'

module ToDeb

WORKING = 'todeb-working-dir'
MAINTAINER_REGEX = /^ *([^<]+) +<([^<>@]+@[^<>@]+)> *$/

class BasicArchive
  attr_reader :spec, :debian_name, :dh_make_name
  def initialize(the_yaml)
    @spec = the_yaml
    @debian_name = "#{@spec['name']}_#{@spec['version']}"
    @dh_make_name = "#{@spec['name']}-#{@spec['version']}"
  end
  def produce_dh_make_ready_directory
    File.directory? WORKING or Dir.mkdir WORKING
    Dir.chdir WORKING do
      Archive.unpack_to_orig_dir(@spec['filesystem'], @dh_make_name)
    end
  end
  def run_dh_make
    begin
      cmd = %w| dh_make --createorig --indep |
      STDERR.puts "Running `dh_make'."
      Dir.chdir("#{WORKING}/#{@dh_make_name}") do
        env_set
        system *cmd
      end
    ensure
      env_unset
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
    ENV['PWD'] = Dir.pwd
  end
  def env_unset
    @originals.each do |var, val|
      ENV[var] = val
    end if @originals
  end
end

end

