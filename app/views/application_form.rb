# frozen_string_literal: true

class ApplicationForm < PhlexForm
  def field(attribute, type: nil, **attributes)
    fieldset do
      errors = @model.errors[attribute]
      column = @model.column_for_attribute attribute
      legend { attribute.to_s.capitalize }
      attributes.merge!(aria_invalid: "true") if errors.any?
      case { type: column.type }
        in type: :text
          textarea_field field: attribute, **attributes
        else
          input_field field: attribute, **attributes
      end
      if errors.any?
        small { "#{attribute.to_s.capitalize} #{errors.to_sentence}" }
      end
    end
  end

  def permit(params)
    params.require(@model.model_name.param_key).permit(*@fields)
  end
end
