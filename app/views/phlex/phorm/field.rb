class Phlex::Phorm::Field
  include ActionView::Helpers::FormTagHelper

  def initialize(object:, attribute:, namespace: nil, type: nil, value: nil)
    @object = object
    @attribute = attribute
    @namespace = Array(namespace) + Array(attribute)
    @type = type
    @value = value
    @object.send @attribute
  end

  class LabelComponent < ApplicationComponent
    def template(&)
      strong do
        yield_content(&)
      end
    end
  end

  def phlex_html(element)
    case element
      in button: { value: }
        element.tag(id: id, name: name, value: value.to_s) { value.to_s.titleize }
      in textarea:
        element.tag(id: id, name: name) { value }
      in button:
        element.tag(id: id, name: name, value: value.to_s)
      in input:
        element.tag(id: id, name: name, value: value.to_s, type: type)
      in label:
        element.tag(for: id) do
          LabelComponent.new { @attribute.to_s.titleize }
        end
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