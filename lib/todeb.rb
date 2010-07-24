
require 'todeb/archive'

module ToDeb

class BasicArchive
  attr_reader :spec, :debian_name
  def initialize(the_yaml)
    @spec = the_yaml
    @debian_name = "#{@spec['name']}_#{@spec['version']}"
  end
  def produce_debian_ready_directory
    Dir.mkdir @debian_name
    Dir.chdir @debian_name do
      Archive.unpack_to_orig_dir(@spec['files'], @debian_name)
    end
  end
  def archive_name
    "#{@debian_name}.orig#{archive_type}"
  end
private
  def archive_type
    Archive.type(@spec['files'])
  end
end

end

