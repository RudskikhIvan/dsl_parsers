require 'nokogiri'

module DslParsers
  module NokogiriXmlParser
    extend ActiveSupport::Concern
    include DslParsers::BaseParser

    module ClassMethods

      def default_finder
        :xpath
      end

      def available_finders
        [:xpath, :css, :regexp]
      end

    end

    def typecast(value, type)
      value = value.text if value.is_a?(Nokogiri::XML::Element) or value.is_a?(Nokogiri::XML::Attr)
      super value, type
    end

    def string_to_node(xml)
      Nokogiri::XML(xml)
    end

    def node_to_string(node)
      return node.text if node.is_a?(Nokogiri::XML::Element) or node.is_a?(Nokogiri::XML::Attr)
      node
    end

    def select_root(xml)
      return xml if xml.is_a? Nokogiri::XML::NodeSet
      xml = string_to_node(xml) if xml.is_a? String
      node = xml.is_a?(Nokogiri::XML::Document) ? xml.root : xml
      return [node] unless self.class.root

      root_tag = self.class.root

      nodes = node.send(root_finder, root_tag) #css
      nodes = node.send(root_finder, "/#{root_tag}") if nodes.blank?
      nodes = node.send(root_finder, ".//#{root_tag}") if nodes.blank?
      nodes
    end

    class Base
      include NokogiriXmlParser
    end

  end
end