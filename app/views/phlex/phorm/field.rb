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

    class FieldComponent < ApplicationComponent
      attr_reader :field

      def initialize(field:, attributes: {})
        @field = field
        @attributes = attributes
      end

      def field_name
        @field.dom.name
      end

      def field_title
        @field.key.to_s.titleize
      end

      def field_id
        @field.dom.id
      end

      def field_value
        @field.value.to_s
      end

      def field_attributes
        {}
      end

      private

      def attributes
        field_attributes.merge(@attributes)
      end
    end

    class LabelComponent < FieldComponent
      def template(&)
        label(**attributes) { field_title }
      end

      def field_attributes
        { for: field_id }
      end
    end

    class ButtonComponent < FieldComponent
      def template(&)
        button(**attributes) { field_value.titleize }
      end

      def field_attributes
        { id: field_id, name: field_name, value: field_value }
      end
    end

    class InputComponent < FieldComponent
      def template(&)
        input(**attributes)
      end

      def field_attributes
        { id: field_id, name: field_name, value: field_value, type: field_type }
      end

      def field_type
        case field.value
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

    class TextareaComponent < FieldComponent
      def template(&)
        textarea(**attributes) { field_value }
      end

      def field_attributes
        { id: field_id, name: field_name }
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
