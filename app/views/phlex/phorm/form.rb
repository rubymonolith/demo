module Phlex::Phorm
  class Form < Phlex::HTML
    attr_reader :model

    delegate :permit, :key, to: :@field
    delegate :field, :fields, :collection, to: :@field_components

    class FieldComponents
      attr_accessor :field

      def initialize(field)
        @field = field
      end

      include Components

      def button(**attributes)
        Components::ButtonComponent.new(field: @field, attributes: attributes)
      end

      def input(**attributes)
        Components::InputComponent.new(field: @field, attributes: attributes)
      end

      def label(**attributes)
        Components::LabelComponent.new(field: @field, attributes: attributes)
      end

      def textarea(**attributes)
        Components::TextareaComponent.new(field: @field, attributes: attributes)
      end

      def field(*args, **kwargs, &)
        self.class.new(@field.field(*args, **kwargs)).tap do |components|
          yield components if block_given?
        end
      end

      def fields(*keys, **kwargs)
        keys.map { |key| field(key, **kwargs) }
      end

      def collection(*args, **kwargs, &)
        self.class.new(@field.collection(*args, **kwargs)).tap do |components|
          yield components if block_given?
        end
      end
    end

    def initialize(model, action: nil, method: nil)
      @model = model
      @action = action
      @method = method
      @field = Field.new(model.model_name.param_key, value: model)
      @field_components = FieldComponents.new @field
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
end