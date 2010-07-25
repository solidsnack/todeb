
require 'todeb/archive'

module ToDeb

WORKING = 'todeb-working-dir'

class BasicArchive
  attr_reader :spec, :debian_name
  def initialize(the_yaml)
    @spec = the_yaml
    @debian_name = "#{@spec['name']}_#{@spec['version']}"
    @dh_make_name = "#{@spec['name']}-#{@spec['version']}"
  end
  def produce_debian_ready_directory
    File.directory? WORKING or Dir.mkdir WORKING
    Dir.chdir WORKING do
      Archive.unpack_to_orig_dir(@spec['filesystem'], @dh_make_name)
    end
  end
private
  def archive_type
    Archive.type(@spec['filesystem'])
  end
end

end

