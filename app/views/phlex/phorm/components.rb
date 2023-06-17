module Phlex::Phorm::Components
  class FieldComponent < ApplicationComponent
    attr_reader :parameter, :dom

    def initialize(parameter, attributes: {})
      @parameter = parameter
      @attributes = attributes
      @dom = Phlex::Phorm::DOM.new(parameter)
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
      label(**attributes) { dom.title }
    end

    def field_attributes
      { for: dom.id }
    end
  end

  class ButtonComponent < FieldComponent
    def template(&block)
      button(**attributes) { dom.value.titleize }
    end

    def field_attributes
      { id: dom.id, name: dom.name, value: dom.value }
    end
  end

  class InputComponent < FieldComponent
    def template(&)
      input(**attributes)
    end

    def field_attributes
      { id: dom.id, name: dom.name, value: dom.value, type: type }
    end

    def type
      case parameter.value
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
      textarea(**attributes) { dom.value }
    end

    def field_attributes
      { id: dom.id, name: dom.name }
    end
  end
end