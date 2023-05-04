class Phlex::Phorm::Field
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

  def button_attributes
    { value: value, id: id, name: name }
  end

  class LabelComponent < ApplicationComponent
    def template(&)
      strong do
        yield_content(&)
      end
    end
  end

  def label_content
    LabelComponent.new { @attribute.to_s.titleize }
  end

  def textarea_content
    value
  end

  def textarea_attributes
    { id: id, name: name }
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