module Phlex::Phorm
  class Parameter
    attr_reader :parent, :children, :key, :dom

    attr_accessor :value

    def initialize(key = nil, value: nil, parent: nil, permitted: true)
      @key = key
      @parent = parent
      @children = []
      @value = value || parent_value
      @permitted = permitted

      yield self if block_given?
    end

    def permitted?
      @permitted
    end

    def assign(attributes)
      @children.each do |child|
        case value = attributes[child.key]
        when Hash, Array
          child.assign(value)
        else
          child.value = value if child.permitted?
        end
      end
    end

    def permit(params)
      assign params.require(key)
      to_h
    end

    def collection(key, **kwargs)
      add_child Collection.new(key, parent: self, **kwargs)
    end

    def field(key, **kwargs, &)
      add_child self.class.new(key, parent: self, **kwargs), &
    end

    def to_h
      @children.each_with_object Hash.new do |child, hash|
        hash[child.key] = child.children? ? child.to_h : child.value
      end
    end

    def children?
      @children.any?
    end

    private

    def parent_value
      @parent.value.send @key if @key and @parent and @parent.value and @parent.value.respond_to? @key
    end

    def add_child(field, &block)
      @children << field
      block.call field if block
      field
    end
  end
end
