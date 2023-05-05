class Phlex::Phorm::Field
  include ActionView::Helpers::FormTagHelper

  def initialize(model:, attribute:, namespace: nil, type: nil)
    @model = model
    @attribute = attribute
    @namespace ||= infer_namespace(model)
    @type = type
  end

  class LabelComponent < ApplicationComponent
    def template(&)
      strong do
        yield_content(&)
      end
    end
  end

  def html_content(tag)
    case tag
    when :label
      LabelComponent.new { @attribute.to_s.titleize }
    when :textarea
      value.to_s
    end
  end

  def html_attributes(tag)
    case tag
    when :label
      { for: id }
    when :textarea
      { id: id, name: name }
    when :button
      { id: id, name: name, value: value.to_s }
    when :input
      { id: id, name: name, value: value.to_s, type: type }
    end
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