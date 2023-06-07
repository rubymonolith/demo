module Phlex::Phorm
  class Field
    attr_reader :parent, :children, :key, :dom

    attr_accessor :value

    def initialize(key = nil, value: nil, parent: nil, permitted: true)
      @key = key
      @parent = parent
      @children = []
      @value = value || parent_value
      @permitted = permitted
      @dom = DOM.new(field: self)
      yield self if block_given?
    end

    def permitted?
      @permitted
    end

    def name
      @key unless @parent.is_a? Collection
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

    def parents
      field = self
      Enumerator.new do |y|
        while field = field.parent
          y << field
        end
      end
    end

    class LabelComponent < ApplicationComponent
      def initialize(field:, attributes: {})
        @field = field
        @attributes = attributes
      end

      def template(&)
        label(**attributes) do
          @field.key.to_s.titleize
        end
      end

      def attributes
        { for: @field.dom.id }.merge(@attributes)
      end
    end

    class ButtonComponent < ApplicationComponent
      def initialize(field:, attributes: {})
        @field = field
        @attributes = attributes
      end

      def template(&)
        button(**attributes) do
          @field.value.to_s.titleize
        end
      end

      def attributes
        { id: @field.dom.id, name: @field.dom.name, value: @field.value.to_s }
      end
    end

    class InputComponent < ApplicationComponent
      def initialize(field:, attributes: {})
        @field = field
        @attributes = attributes
      end

      def template(&)
        input(**attributes.merge(@attributes))
      end

      def attributes
        { id: @field.dom.id, name: @field.dom.name, value: @field.value.to_s, type: type }
      end

      def type
        case @field.value
        when URI
          "url"
        when Integer
          "number"
        when Date, DateTime
          "date"
        when Time
          "time"
        else
          "text"
        end
      end
    end

    class TextareaComponent < ApplicationComponent
      def initialize(field:, attributes: {})
        @field = field
        @attributes = attributes
      end

      def template(&)
        textarea(**attributes.merge(@attributes)) do
          @field.value
        end
      end

      def attributes
        { id: @field.dom.id, name: @field.dom.name }
      end
    end

    def input(**attributes)
      InputComponent.new(field: self, attributes: attributes)
    end

    def label(**attributes)
      LabelComponent.new(field: self, attributes: attributes)
    end

    def textarea(**attributes)
      TextareaComponent.new(field: self, attributes: attributes)
    end

    def button(**attributes)
      ButtonComponent.new(field: self, attributes: attributes)
    end

    def collection(key, **kwargs, &)
      add_child Collection.new(key, parent: self, **kwargs), &
    end

    def field(key, **kwargs, &)
      add_child Field.new(key, parent: self, **kwargs), &
    end

    def to_h
      @children.each_with_object Hash.new do |child, hash|
        hash[child.name] = child.children? ? child.to_h : child.value
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
