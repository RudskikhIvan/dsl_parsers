module DslParsers
  module NokogiriHtmlParser
    extend ActiveSupport::Concern
    include DslParsers::NokogiriXmlParser

    module ClassMethods

      def default_finder
        :css
      end

    end

    def string_to_node(xml)
      Nokogiri::HTML(xml)
    end

    class Base
      include NokogiriHtmlParser
    end

  end
end