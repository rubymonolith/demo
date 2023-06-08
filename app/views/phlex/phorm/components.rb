module Phlex::Phorm::Components
  class FieldComponent < ApplicationComponent
    attr_reader :field

    def initialize(field:, attributes: {})
      @field = field
      @attributes = attributes
      @dom = Phlex::Phorm::DOM.new(@field)
    end

    def field_name
      @dom.name
    end

    def field_id
      @dom.id
    end

    def field_title
      @field.key.to_s.titleize
    end

    def field_value
      @field.value
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
      label(**attributes) { field_title }
    end

    def field_attributes
      { for: field_id }
    end
  end

  class ButtonComponent < FieldComponent
    def template(&block)
      button(**attributes) { field_value.to_s.titleize }
    end

    def field_attributes
      { id: field_id, name: field_name, value: field_value }
    end
  end

  class InputComponent < FieldComponent
    def template(&)
      input(**attributes)
    end

    def field_attributes
      { id: field_id, name: field_name, value: field_value, type: field_type }
    end

    def field_type
      case field_value
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
      textarea(**attributes) { field_value }
    end

    def field_attributes
      { id: field_id, name: field_name }
    end
  end
end