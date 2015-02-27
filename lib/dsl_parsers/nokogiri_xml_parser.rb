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
      xml = string_to_node(xml) if xml.is_a? String
      node = xml.is_a?(Nokogiri::XML::Element) ? xml.root : xml
      root_tag = self.class.root

      return [node] unless root_tag

      if node.is_a?(Nokogiri::XML::Element) and (node.name == root_tag)
        return [node]
      else
        nodes = node.send(root_finder, root_tag)
        nodes = node.send(root_finder, ".//#{root_tag}") if nodes.blank?
        return nodes
      end

    end

    class Base
      include NokogiriXmlParser
    end

  end
end