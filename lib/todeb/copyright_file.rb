
# The machine-readable Debian copyright file format, per DEP 5.
#   http://dep.debian.net/deps/dep5/

module ToDeb
class CopyrightFile

FORMAT = 'http://svn.debian.org/wsvn/dep/web/deps/dep5.mdwn?op=file&rev=135'

MAIN_STANZA_FIELDS_IN_ORDER = %w| Format-Specification Name Maintainer Source |
SUBORDINATE_STANZA_FIELDS_IN_ORDER = %w| Files Copyright License |


class << self
  def from_yaml(yaml)
    files_basic = case
                  when yaml['license']
                    splitter = /[[:space:]]*\/\/[[:space:]]*/
                    license, attributions = v.split(splitter)
                    unless license and not attributions.empty?
                      raise FormatError, v
                    end
                    joiner = "\n#{' ' * "Copyright: ".length}"
                    [ Field.new('Files: *'),
                      Field.new("License: #{license}"),
                      Field.new("Copyright: #{attributions.join(joiner)}") ]
                  end
    main_basic = [ Field.new("Format-Specification: #{FORMAT}") ]
    # A literal in the YAML can be handled later.
    CopyrightFile.new(main_basic, [files_basic].compact)
  end
end

attr_reader :fields
def initialize(main_stanza, *subordinate_stanzas)
  @main_stanza = main_stanza
  raise NoStanzasError if subordinate_stanzas.empty?
  @subordinate_stanzas = subordinate_stanzas
end

def display
  ([@main_stanza] + @subordinate_stanzas).map do |stanza|
    stanza.fields.map{|field| field.text }.join("\n")
  end.join("\n\n")
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

class Stanza
end

class FormatError < RuntimeError
end

class NoStanzasError < RuntimeError
end

end
end

