# frozen_string_literal: true

class ApplicationForm < PhlexForm
  def field(attribute, type: nil)
    div do
      errors = @model.errors[attribute]
      label { attribute.to_s.capitalize }
      text_field attribute
      if errors.any?
        div(class: "text-red-500") { errors.to_sentence }
      end
    end
  end

  def permit(params)
    params.require(@model.model_name.param_key).permit(*@fields)
  end
end
