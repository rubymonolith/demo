module Phlex::Phorm::Components
  class FieldComponent < ApplicationComponent
    attr_reader :field

    def initialize(field:, attributes: {})
      @field = field
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
      label(**attributes) { field.key.to_s.titleize }
    end

    def field_attributes
      { for: field.id }
    end
  end

  class ButtonComponent < FieldComponent
    def template(&block)
      button(**attributes) { field.value.to_s.to_s.titleize }
    end

    def field_attributes
      { id: field.id, name: field.name, value: field.value.to_s }
    end
  end

  class InputComponent < FieldComponent
    def template(&)
      input(**attributes)
    end

    def field_attributes
      { id: field.id, name: field.name, value: field.value.to_s, type: field_type }
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
      textarea(**attributes) { field.value.to_s }
    end

    def field_attributes
      { id: field.id, name: field.name }
    end
  end
end