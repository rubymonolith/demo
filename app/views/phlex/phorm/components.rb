module Phlex::Phorm::Components
  class FieldComponent < ApplicationComponent
    attr_reader :parameter

    def initialize(parameter, attributes: {})
      @parameter = parameter
      @attributes = attributes
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
      label(**attributes) { parameter.key.to_s.titleize }
    end

    def field_attributes
      { for: parameter.id }
    end
  end

  class ButtonComponent < FieldComponent
    def template(&block)
      button(**attributes) { parameter.value.to_s.to_s.titleize }
    end

    def field_attributes
      { id: parameter.id, name: parameter.name, value: parameter.value.to_s }
    end
  end

  class InputComponent < FieldComponent
    def template(&)
      input(**attributes)
    end

    def field_attributes
      { id: parameter.id, name: parameter.name, value: parameter.value.to_s, type: parameter_type }
    end

    def parameter_type
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
      textarea(**attributes) { parameter.value.to_s }
    end

    def field_attributes
      { id: parameter.id, name: parameter.name }
    end
  end
end