module Phlex::Phorm
  class Collection
    include Enumerable

    attr_reader :key, :parent

    def initialize(key, schema:, parent:, &block)
      @key = key
      @children = []
      @schema = schema
      @block = block
    end

    def each(&)
      @children.each(&)
    end

    def assign(array)
      array.each.with_index do |value, index|
        @children.append build_namespace(index).tap { |template| template.assign value }
      end
    end

    def serialize
      map(&:serialize)
    end

    private

    def build_namespace(key, value: nil)
      Namespace.new(key, schema: @schema, parent: self, &@block)
    end
  end
end
