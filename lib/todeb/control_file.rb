
# Field names and required/optional stuff are listed here:
#   http://www.debian.org/doc/debian-policy/ch-controlfields.html

module ToDeb
module ControlFile
  class FormatError < RuntimeError
  end
  class Field
    attr_reader :text, :order, :name, :value
    def initialize(text, order)
      @text = text
      @order = order
      traits = Field.parse(text)
      @name = traits[:name]
      @value = traits[:value]
    end
    class << self
      def parse(text)
        text.lines.inject({ :started => false }) do |acc, line|
          case line
          when /^#/
            # Skip comments.
          when /^([^\t :]+):[ \t]+([^\t ]+)$/
            raise FormatError if acc[:started]
            acc[:name] = $1
            acc[:value] = $2
          when /^[\t ]+([^\t ].+)$/
            raise FormatError unless acc[:started]
            acc[:value] = "#{acc[:value]}\n#{$1}"
          when /^[\t ]*$/
            raise FormatError
          end
          acc
        end
      end
    end
  end
  module Paragraph
    module Base
      def lookup(name)
        @fields[name]
      end
      def update(name, string)
        order = @fields[name].order
        @fields[name] = Field.new("#{name}: #{string}", order)
      end
    end
    class SourcePackageGeneralParagraph
      FIELDS_DESC = <<-DESC
        Source (mandatory)
        Maintainer (mandatory)
        Uploaders
        Section (recommended)
        Priority (recommended)
        Build-Depends
        Standards-Version (recommended)
        Homepage
                       DESC
    end
    class SourcePackageBinaryParagraph
      FIELDS_DESC = <<-DESC
        Package (mandatory)
        Architecture (mandatory)
        Section (recommended)
        Priority (recommended)
        Essential
        Depends
        Description (mandatory)
        Homepage
                       DESC
    end
    class BinaryPackageParagraph
      FIELDS_DESC = <<-DESC
        Package (mandatory)
        Source
        Version (mandatory)
        Section (recommended)
        Priority (recommended)
        Architecture (mandatory)
        Essential
        Depends
        Installed-Size
        Maintainer (mandatory)
        Description (mandatory)
        Homepage
                       DESC
    end
    class SourceDSCParagraph
      FIELDS_DESC = <<-DESC
        Format (mandatory)
        Source (mandatory)
        Binary
        Architecture
        Version (mandatory)
        Maintainer (mandatory)
        Uploaders
        Homepage
        Standards-Version (recommended)
        Build-Depends
        Checksums-Sha1 (recommended)
        Checksums-Sha256 (recommended)
        Files (mandatory)
                       DESC
    end
  extend self
    def check_paragraph_fields(paragraph_class, fields)
      # Some day, log instead of sending to STDERR.
      info = self.info_from_desc(paragraph_class::FIELDS_DESC)
      missing = info.keys - fields.keys
      unknown = fields.keys - info.keys
      missing.each do |field|
        if info[field]
          STDERR.puts "Missing field `#{field}' is `#{info[field]}'."
        end
      end
      unknown.each do |field|
        STDERR.puts "Unknown field `#{field}'."
      end
    end
    def info_from_desc(desc)
      desc.lines.inject({}) do |acc, line|
        m = /^ *([^ #]+)( +(.+))?$/.match(line)
        acc[m[1]] = m[3] if m
        acc
      end
    end
    def paragraph_from_text(paragraph_class, s)
      field_array = s.lines.inject([]) do |acc, line|
        case line
        when /^[\t ]*$/
          raise FormatError
        when /^[^\t #:]+:[\t ]+([^\t ].+)$/
          acc << line
        else
          raise FormatError unless acc[-1]
          acc[-1] = "#{acc[-1]}\n#{line}"
        end
      end
      field_array.each_with_index do |text, i|
        f = Field.new(text, i)
        @fields[f.name] = f
      end
      check_fields(paragraph_class, @fields)
    end
  end
end
end


