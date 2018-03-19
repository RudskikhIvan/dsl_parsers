# Examples from https://github.com/ohler55/ox/blob/master/lib/ox/element.rb
# * <code>element.locate("Family/Pete/*")</code> returns all children of the Pete Element.
# * <code>element.locate("Family/?[1]")</code> returns the first element in the Family Element.
# * <code>element.locate("Family/?[<3]")</code> returns the first 3 elements in the Family Element.
# * <code>element.locate("Family/?/@age")</code> returns the arg attribute for each child in the Family Element.
# * <code>element.locate("Family/*/@type")</code> returns the type attribute value for decendents of the Family.
# * <code>element.locate("Family/^Comment")</code> returns any comments that are a child of Family.
require 'ox'

module DslParsers
  module OxXmlParser
    extend ActiveSupport::Concern
    include DslParsers::BaseParser

    module ClassMethods

      def default_finder
        :locate
      end

      def available_finders
        [:locate, :regexp]
      end

    end

    def string_to_node(xml)
      Ox.parse(xml)
    end

    def node_to_string(node)
      if node.is_a?(Ox::Element)
        return if node.nodes.blank?
        node.nodes.each do |n|
          case n
          when String then return n
          when Ox::CData then return n.value.strip
          end
        end
      end
      node
    end

    def select_root(xml)
      xml = string_to_node(xml) if xml.is_a? String
      node = xml.is_a?(Ox::Document) ? xml.root : xml
      root_tag = self.class.root

      return [node] unless root_tag

      nodes = node.locate(root_tag)
      nodes = node.locate("/#{root_tag}") if nodes.blank?
      nodes = node.locate("*/#{root_tag}") if nodes.blank?
      nodes
    end

    class Base
      include OxXmlParser
    end

  end
end
