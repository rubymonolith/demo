class PhlexForm < Phlex::HTML
  DEFAULT_INPUT_TYPE = "text".freeze

  attr_reader :fields, :model

  def initialize(model)
    @model = model
    @fields = Set.new
  end

  def around_template(&)
    form action: url, method: "post" do
      authenticity_token_field
      _method_field
      super
    end
  end

  def template(&block)
    yield_content(&block)
  end

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
      type: :hidden,
      value: _method_field_value)
  end

  def _method_field_value
   @model.persisted? ? "patch" : "post"
  end

  def submit(value = submit_value)
    input(
      name: "commit",
      type: "submit",
      value: value
    )
  end

  def submit_value
    "#{action.to_s.capitalize} #{@model.model_name}"
  end

  def action
    @model.persisted? ? :update : :create
  end

  def url
    helpers.url_for(action: action)
  end

  def self.polymorphic_tag(method_name)
    attributes_method_name = "#{method_name}_attributes"
    value_method_name = "#{method_name}_value"

    define_method method_name do |object = nil, **attributes, &content|
      if object.respond_to? attributes_method_name
        attributes = object.send(attributes_method_name).merge(attributes)
      end

      if object.respond_to? value_method_name
        # TODO: Ideally I could pass just the method or call to_proc on it. Joel said he's going
        # to add support for this, so see where thats at.
        content ||= Proc.new { object.method(value_method_name).call }
      end

      super(**attributes, &content)
    end
  end

  polymorphic_tag :textarea
  polymorphic_tag :input
  polymorphic_tag :label

  class Field
    include ActionView::Helpers::FormTagHelper

    def initialize(model:, attribute:, namespace: nil, type: nil)
      @model = model
      @attribute = attribute
      @namespace ||= infer_namespace(model)
      @type = type
    end

    def input_attributes
      { value: value, id: id, name: name, type: type }
    end

    def label_attributes
      { for: id }
    end

    def label_value
      @attribute.to_s.titleize
    end

    def value
      @model.send @attribute
    end

    def id
      field_id @namespace.last, @attribute
    end

    def name
      field_name @namespace.last, @attribute
    end

    def type
      @type ||= infer_type(value)
    end

    protected

    def infer_namespace(object)
      Array(object.model_name.param_key)
    end

    def infer_type(name)
      return "email" if name == "email"

      case value
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

  def field(attribute)
    Field.new model: @model, attribute: attribute
  end
end
