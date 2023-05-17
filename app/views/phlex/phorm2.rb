module Phlex::Phorm2
  class Form < Phlex::HTML
    attr_reader :model

    delegate :field, :collection, :to_h, :permitted_keys, to: :@field

    def initialize(model, action: nil, method: nil)
      @model = model
      @action = action
      @method = method
      @field = Field.new(model.model_name.param_key, value: model)
    end

    def around_template(&)
      form action: form_action, method: form_method do
        authenticity_token_field
        _method_field
        super
      end
    end

    def template(&block)
      yield_content(&block)
    end

    def submit(value = submit_value)
      input(
        name: "commit",
        type: "submit",
        value: value
      )
    end

    def permit(params)
      params.require(@field.key).permit(*@field.permitted_keys)
    end

    protected

    def authenticity_token_field
      input(
        name: "authenticity_token",
        type: "hidden",
        value: helpers.form_authenticity_token
      )
    end

    def _method_field
      input(
        name: "_method",
        type: "hidden",
        value: _method_field_value
      )
    end

    def _method_field_value
      @method || @model.persisted? ? "patch" : "post"
    end

    def submit_value
      "#{resource_action.to_s.capitalize} #{@model.model_name}"
    end

    def resource_action
      @model.persisted? ? :update : :create
    end

    def form_action
      @action ||= helpers.url_for(action: resource_action)
    end

    def form_method
      @method.to_s.downcase == "get" ? "get" : "post"
    end
  end

  class Field
    include ActionView::Helpers::FormTagHelper

    attr_reader :value, :parent, :children, :key

    def initialize(key = nil, value: nil, parent: nil, permitted: true)
      @key = key
      @parent = parent
      @children = []
      @value = value || parent_value
      @permitted = true
      yield self if block_given?
    end

    def permitted?
      @permitted
    end

    def name
      @key unless @parent.is_a? Collection
    end

    def permit(params)
      params.require(@key).permit(*permitted_keys)
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
        { for: @field.dom_id }.merge(@attributes)
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
        { id: @field.dom_id, name: @field.dom_name, value: @field.value.to_s }
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
        { id: @field.dom_id, name: @field.dom_name, value: @field.value.to_s, type: type }
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
        { id: @field.dom_id, name: @field.dom_name }
      end
    end

    def input(**attributes)
      InputComponent.new(field: self, attributes: attributes)
    end

    def label(**attributes)
      LabelComponent.new(field: self)
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

    def field(key = nil, **kwargs, &)
      add_child Field.new(key, parent: self, **kwargs), &
    end

    def add_child(field, &block)
      @children << field
      yield field if block_given?
      field
    end

    def dom_name
      field_name *name_keys
    end

    def dom_id
      field_id *name_keys
    end

    def id_keys
      parents.map(&:key).reverse.append(key)
    end

    def name_keys
      parents.map(&:name).reverse.append(name)
    end

    def permitted_keys
      children(&:permitted).map do |child|
        if child.permitted_keys.any?
          { child.key => child.permitted_keys }
        else
          child.key
        end
      end
    end

    def to_h
      @children.each_with_object({}) do |f, h|
        h[f.name] = f.children.any? ? f.to_h : f.value
      end
    end


    private

    def parent_value
      @parent.value.send @key if @key and @parent and @parent.value and @parent.value.respond_to? @key
    end
  end

  class Collection < Field
    include Enumerable

    def values
      Enumerator.new do |y|
        @value.each.with_index do |value, index|
          y << field(index, value: value)
        end
      end
    end

    def to_h
      @children.map do |child|
        child.children.any? ? child.to_h : child.value
      end
    end

    def each(&)
      values.each(&)
    end
  end
end
