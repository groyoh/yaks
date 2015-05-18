module Yaks
  class Primitivize
    attr_reader :mappings, :mappings_order

    def initialize
      @mappings = {}
      @mappings_order = []
    end

    def call(object)
      mappings_order.each do |pattern|
        # rubocop:disable Style/CaseEquality
        block = mappings[pattern]
        return instance_exec(object, &block) if pattern === object
      end
      raise PrimitivizeError, "don't know how to turn #{object.class} (#{object.inspect}) into a primitive"
    end

    def map(*types, &block)
      types.each do |type|
        @mappings_order << type unless mappings.key?(type)
        @mappings = mappings.merge(type => block)
      end
      mappings_order.sort! { |a, b| (a <=> b).to_i }
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
