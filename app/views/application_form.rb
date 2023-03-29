# frozen_string_literal: true

class ApplicationForm < PhlexForm
  def field(attribute, type: nil)
    fieldset do
      errors = @model.errors[attribute]
      column = @model.column_for_attribute attribute
      legend { attribute.to_s.capitalize }
      case { type: column.type }
        in type: :text
          textarea_field field: attribute
        else
          input_field field: attribute
      end
      if errors.any?
        div(class: "invalid") { errors.to_sentence }
      end
    end
  end

  def permit(params)
    params.require(@model.model_name.param_key).permit(*@fields)
  end
end
