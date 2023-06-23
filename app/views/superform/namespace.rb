module Superform
  class Namespace
    include Enumerable

    attr_reader :key, :schema, :parent

    def initialize(key, schema: nil, parent: nil, object: nil, builder: Builder.new)
      @key = key
      @children = Hash.new
      @schema = schema || Schema.new(key)
      @parent = parent
      @object = object
      @builder = builder

      yield self if block_given?
    end

    def namespace(key, permit: true, object: nil, &)
      return @children[key] if @children.key? key
      object ||= @object.send(key) if @object.respond_to? key
      schema = @schema.permit(key, permit: permit)

      append_child @builder.namespace(key, schema: schema, parent: self, object: object, &)
    end

    def collection(key, permit: true, object: nil, &)
      return @children[key] if @children.key? key
      object ||= @object.send(key) if @object.respond_to? key
      schema = @schema.permit(key, permit: permit)

      append_child @builder.collection(key, schema: schema, parent: self, object: object, &)
    end

    def field(key, permit: true, value: nil, &)
      return @children[key] if @children.key? key
      value ||= @object.send(key) if @object.respond_to? key
      @schema.permit(key, permit: permit)

      append_child @builder.field(key, parent: self, value: value, &)
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