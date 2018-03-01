class Boolean; end

module DslParsers
  module BaseParser
    extend ActiveSupport::Concern

    Types = [String, Float, Time, Date, DateTime, Integer, Boolean, Array, BigDecimal]

    class ConfigurationError < RuntimeError; end
    class ParsingError < RuntimeError; end

    included do
      class_attribute :map, :instance_accessor => false
      class_attribute :root, :instance_accessor => false
      class_attribute :many, :instance_accessor => false
      self.map = {}
    end

    def before_parse(data)
      data
    end

    def parse(data)
      return if data.blank?
      nodes = select_root(before_parse(data))
      res = Array.wrap(recurse_parse(nodes, self.class.map))
      after_parse(self.class.many ? res : res.first)
    end

    def after_parse(res)
      res
    end

    def select_root(raw_data)
      raise ConfigurationError, "method '#{__method__}' is not defined for #{self.class}"
    end

    def recurse_parse(nodes, map)
      nodes.collect do |n|
        obj = wrapper_result_class.new
        map.each do |k,v|
          obj[k] = find(n,v)
        end
        obj
      end
    end

    def wrapper_result_class
      Hash
    end

    def root_finder
      self.class.default_finder
    end

    def find(node, params)

      map = params[:map] || String
      nodes = find_node(node, params)

      #convert by type
      if primitive? map
        return params[:many] ? nodes.map{|n| typecast(n, map)} : typecast(nodes.first, map)
      elsif map.respond_to?(:parse)
        return params[:many] ? nodes.map{|n| map.parse(n) } : map.parse(nodes.first)
      end

      #recursive parse
      if map.is_a?(Hash)
        if params[:many]
          return recurse_parse(nodes, map)
        else
          return recurse_parse([nodes.first], map).first
        end
      end

      #call Proc
      if params[:map].is_a?(Proc)
        return instance_exec((params[:many] ? nodes : nodes.first), &params[:map])
      end

      #call instance method
      if params[:map].is_a?(Symbol) || params[:map].is_a?(String)
        return self.send(params[:map],  params[:many] ? nodes : nodes.first )
      end

      # #parse with class, which has parse method
      # if map.respond_to?(:parse)
      #   res = Array.wrap( params[:map].parse(nodes) )
      #   return params[:many] ? res : res.first
      # end

    end

    def primitive?(type)
      return true if type.nil?
      Types.include?(type)
    end

    def find_node(node, params)
      #return node if params[:path].blank?
      finder_method = params[:finder_method]
      return node.to_s.scan(params[:path]) if finder_method == :regexp
      node.send(finder_method, params[:path])
    end

    def node_to_string(xml)
      xml
    end

    def typecast(value, type)
      return value if value.nil?
      value = node_to_string(value)
      begin
        if type == String then value.to_s
        elsif type == Float then value.to_f
        elsif type == Time then Time.parse(value.to_s) rescue Time.at(value.to_i)
        elsif type == Date then Date.parse(value.to_s)
        elsif type == DateTime then DateTime.parse(value.to_s)
        elsif type == Boolean then ['true', 't', '1'].include?(value.to_s.downcase)
        elsif type == Array then Array.wrap(value)
        elsif type == Integer then value.to_i
        elsif type == BigDecimal then value.to_d
        elsif type.respond_to
          value
        end
      rescue
        nil
      end
    end

    module ClassMethods

      def parse(data)
        p = self.new
        p.parse(data)
      end

      private

      def has_one(name, path, type = nil, params = {})
        self.map = self.map.dup unless @map_inited
        @map_inited = true
        self.map[name] = normalize_arguments(path, type, params)

        finder = self.map[name][:finder_method]

        unless available_finders.include? finder
          raise ConfigurationError, "Unknown finder '#{finder}', available finders are #{available_finders.join(', ')}"
        end

        return unless block_given?

        self.map[name][:map] = {}
        before_map = self.map
        self.map = before_map[name][:map]
        yield
        self.map = before_map
      end

      def has_many(name, path, type = nil, params = {}, &block)
        params = normalize_arguments(path, type, params)
        params[:many] = true
        has_one(name, params, &block)
      end

      def few(many)
        self.many = !!many
      end

      def root_path(path)
        self.root = path
      end

      def normalize_arguments(path, type, params)
        params = path if path.is_a? Hash
        params = type if type.is_a? Hash
        params[default_finder] = path if path.is_a? String
        params[:map] ||= (params.delete(:type) || type || String)
        if params[:finder_method].nil?
          params[:finder_method], params[:path] = params.find{|k,v| available_finders.include?(k) }
        end
        params.delete params[:finder_method]
        params
      end

      def default_finder
        raise ConfigurationError, "method '#{__method__}' is not defined for #{self}"
      end

      def available_finders
        raise ConfigurationError, "method '#{__method__}' is not defined for #{self}"
      end

    end

  end
end
