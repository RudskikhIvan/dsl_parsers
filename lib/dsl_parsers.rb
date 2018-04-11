require 'active_support'
require 'active_support/core_ext'
module DslParsers

  autoload :BaseParser, 'dsl_parsers/base_parser'
  autoload :NokogiriXmlParser, 'dsl_parsers/nokogiri_xml_parser'
  autoload :NokogiriHtmlParser, 'dsl_parsers/nokogiri_html_parser'
  autoload :OxXmlParser, 'dsl_parsers/ox_xml_parser'
  autoload :Enum, 'dsl_parsers/enum'

  def self.Enum(enum, options=Regexp::IGNORECASE)
    raise "#{enum} is not Enumerable" unless enum.respond_to?(:each)
    choices = if enum.to_a.first.is_a?(Array)
                enum.to_a
              else
                enum.map { |c| [Regexp.new(Regexp.escape(c.to_s), options), c] }
              end

    Class.new(Enum) do
      extend DslParsers::OxXmlParser

      define_singleton_method(:choices) do
        choices
      end

      def self.parse(value)
        value = node_to_string(value)
        value = value.strip if value.is_a?(String)

        choices.detect do |test, choice|
          case value
          when test then return choice
          end
        end
      end
    end
  end
end
