module Yaks
  class Primitivize
    class TSortableHash < Hash
      include TSort

      alias tsort_each_node each_key

      def tsort_each_child(node, &block)
        fetch(node).each(&block)
      end
    end

    attr_reader :mappings, :mappings_order, :mappings_dependencies

    def initialize
      @mappings = {}
      @mappings_dependencies = TSortableHash.new
    end

    def call(object)
      mappings_order.each do |pattern|
        block = mappings[pattern]
        return instance_exec(object, &block) if pattern === object # rubocop:disable Style/CaseEquality
      end
      raise PrimitivizeError, "don't know how to turn #{object.class} (#{object.inspect}) into a primitive"
    end
    require "pry"
    def map(*types, &block)
      types.each do |type|
        @mappings = mappings.merge(type => block)
      end
      update_dependencies(types)
      topological_sort
    end

    def update_dependencies(types)
      types.each do |type|
        next if mappings_dependencies.key?(type)
        mappings_dependencies[type] = []
        next unless type.is_a?(Module)
        mappings.keys.each do |pattern|
          break unless pattern.is_a?(Module)
          mappings_dependencies[pattern] << type if type < pattern
#          mappings_dependencies[type] << pattern if type > pattern
        end
      end
    end

    def topological_sort
      @mappings_order = @mappings_dependencies.tsort
    end

    def self.create
      new.tap do |p|
        p.map String, Numeric, true, false, nil do |object|
          object
        end

        p.map Symbol, URI do |object|
          object.to_s
        end

        p.map Hash do |object|
          object.to_enum.with_object({}) do |(key, value), output|
            output[call(key)] = call(value)
          end
        end

        p.map Enumerable do |object|
          object.map(&method(:call))
        end
      end
    end
  end
end
