class Phlex::Phorm::Field
  include ActionView::Helpers::FormTagHelper

  attr_reader :attribute

  def initialize(object:, attribute:, namespace: nil, type: nil, value: nil, permitted: true)
    @object = object
    @attribute = attribute
    @namespace = Array(namespace) + Array(attribute)
    @type = type
    @value = value
    @permitted = permitted
  end

  class LabelComponent < ApplicationComponent
    def initialize(field:)
      @field = field
    end

    def template(&)
      label(**@field.label_attributes) do
        @field.attribute.to_s.titleize
      end
    end
  end

  class InputComponent < ApplicationComponent
    def initialize(field:)
      @field = field
    end

    def template(&)
      input(**@field.input_attributes)
    end
  end

  class TextareaComponent < ApplicationComponent
    def initialize(field:, attributes: {})
      @field = field
      @attributes = @field.textarea_attributes.merge(attributes)
    end

    def template(&)
      textarea(**@attributes) do
        @field.value
      end
    end
  end

  def input(**attributes)
    InputComponent.new(field: self)
  end

  def label(**attributes)
    LabelComponent.new(field: self)
  end

  def textarea(**attributes)
    TextareaComponent.new(field: self, attributes: attributes)
  end

  def textarea_attributes
    { id: id, name: name }
  end

  def label_attributes
    { for: id }
  end

  def input_attributes
    { id: id, name: name, value: value.to_s, type: type }
  end

  def forms
    @value.each do |object|
      Phlex::Phorm::Namespace.new(object: object, namespace: @namespace)
    end
  end

  def values
    @value.each do |value|
      self.class.new(value: value, namespace: @namespace + [[], :foo])
    end
  end

  def value
    @value ||= @object.send @attribute
  end

  def id
    field_id *@namespace
  end

  def name
    field_name *@namespace
  end

  def type
    @type ||= infer_type(value)
  end

  protected

  def infer_type(name)
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