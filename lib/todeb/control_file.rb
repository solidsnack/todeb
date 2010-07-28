
# Field names and required/optional stuff are listed here:
#   http://www.debian.org/doc/debian-policy/ch-controlfields.html

module ToDeb
class ControlFile

PREFERRED_ORDER = %w| Package Version
                      Section Priority
                      Architecture
                      Depends Recommends Suggests Enhances Pre-Depends
                      Provides
                      Breaks Conflicts Replaces
                      Installed-Size
                      Maintainer
                      Description |


class << self
  def from_yaml(yaml)
    fields = yaml.map do |k, v|
      case k
      when 'name'    then Field.new("Package: #{v}")
      when 'contact' then Field.new("Maintainer: #{v}")
      when 'version' then Field.new("Version: #{v}")
      end
    end.compact
    first = ControlFile.new(fields)
    first.override_from(parse(yaml['DEBIAN/control'])) if yaml['DEBIAN/control']
    first
  end
  def parse(text)
    fields = text.lines.inject([]) do |acc, line|
      case line
      when /^#/                   then  # Do nothing.
      when /^[^:]+:([ ]+[^ ].*)?$/ then acc << line
      when /^[ ]+[^ ]+/           then  acc[-1] = acc[-1] + line
      else                              raise FormatError, line
      end
      acc
    end.compact.map{|x| Field.new(x) }
    ControlFile.new(fields)
  end
end

attr_reader :fields
def initialize(fields)
  @fields = fields
end

def set(name, value)
  delete(name)
  @fields << Field.new("#{name}: #{value}")
end

def get(name)
  field = get_field(name)
  field.value if field
end

def get_field(name)
  @fields.select{|f| f.name == name }.first
end

def display
  PREFERRED_ORDER.map do |name|
    STDERR.puts "||#{name}"
    field = get_field(name)
    STDERR.puts "  #{field.text}||" if field
    field.text if field
  end.compact.join("\n")
end

def delete(name)
  @fields.delete_if{|f| f.name == name }
end

def has?(name)
  not @fields.select{|f| f.name == name }.empty?
end

def override_from(other)
  other.fields.each{|field| override_or_add_field(field) }
end

def override_or_add_field(field)
  delete(field.name) if has?(field.name)
  @fields << field
end

class Field
  attr_reader :text
  def initialize(text)
    @text = text.strip
  end
  def name
    split[0]
  end
  def value
    split[1]
  end
private
  def split
    @text.split(/: +/, 2)
  end
end

class FormatError < RuntimeError
end

end
end


