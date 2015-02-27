require 'active_support'
require 'active_support/core_ext'
module DslParsers

  autoload :BaseParser, 'dsl_parsers/base_parser'
  autoload :NokogiriXmlParser, 'dsl_parsers/nokogiri_xml_parser'
  autoload :NokogiriHtmlParser, 'dsl_parsers/nokogiri_html_parser'
  autoload :OxParser, 'dsl_parsers/ox_parser'

end
