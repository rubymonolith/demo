module Phlex::Phorm
  class Field
    attr_reader :parent, :children, :key, :dom

    attr_accessor :value

    delegate :name, :id, to: :dom

    def initialize(key = nil, value: nil, parent: nil, permitted: true)
      @key = key
      @parent = parent
      @children = []
      @value = value || parent_value
      @permitted = permitted
      @dom = DOM.new(self)

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
      add_child Field.new(key, parent: self, **kwargs), &
    end

    def fields(*keys, **kwargs)
      keys.map { |key| field(key, **kwargs) }
    end

    def to_h
      @children.each_with_object Hash.new do |child, hash|
        hash[child.key] = child.children? ? child.to_h : child.value
      end
    end

    def children?
      @children.any?
    end

    def self.register_component(component_class, tag:)
      self.define_method tag do |**attributes|
        component_class.new(field: self, attributes: attributes)
      end
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
