module Phlex::Phorm
  class Namespace
    include Enumerable

    attr_reader :key, :schema, :parent

    def initialize(key, schema: nil, parent: nil)
      @key = key
      @children = Hash.new
      @schema = schema || Schema.new(key)
      @parent = parent
      yield self if block_given?
    end

    def namespace(key, permit: true, &)
      return @children[key] if @children.key? key

      schema = @schema.permit(key, permit: permit)
      append_child Namespace.new(key, schema: schema, parent: self, &)
    end

    def collection(key, permit: true, &)
      return @children[key] if @children.key? key
      schema = @schema.permit(key, permit: permit)
      append_child Collection.new(key, schema: schema, parent: self, &)
    end

    def field(key, permit: true, value: nil, &)
      @schema.permit(key, permit: permit)
      append_child Field.new(key, parent: self, value: value, &)
    end

    def each(&)
      @children.values.each(&)
    end

    def assign(hash)
      each do |child|
        next unless hash.key? child.key
        child.assign hash.fetch child.key
      end
    end

    def serialize
      each_with_object Hash.new do |child, hash|
        hash[child.key] = child.serialize
      end
    end

    private

    def append_child(field)
      @children[field.key] = field
      field
    end
  end
end