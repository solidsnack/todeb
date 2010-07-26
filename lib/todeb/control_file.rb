
# Field names and required/optional stuff are listed here:
#   http://www.debian.org/doc/debian-policy/ch-controlfields.html

module ToDeb
class ControlFile

class << self
  def generate_from(yaml)
    fields = yaml.map do |k, v|
      case k
      when 'contact'
      when 'version'
      end
    end
  end
  def parser(text)
    fields = text.lines.inject([]) do |acc, line|
      case line
      when /^#/                   then  # Do nothing.
      when /^ +$/                 then  acc << nil
      when /^[^:]+:([ ]+[^ ]*)?$/ then  acc << line
      when /^[ ]+[^ ]+/           then  acc[-1] = acc[-1] + "\n" + line
      else                              raise FormatError
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
  field = @fields.first{|f| f.name == name }
  field.value if field
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
    @text = text
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


