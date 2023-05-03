# frozen_string_literal: true

class ApplicationForm < PhlexForm
  def input_field(field_name, **attributes)
    form_row(field_name) do
      input field(field_name), **attributes
    end
  end

  def textarea_field(field_name, **attributes)
    form_row(field_name) do
      textarea field(field_name), **attributes
    end
  end

  def form_row(field_name)
    div do
      errors = @model.errors[field_name]
      label field(field_name)
      attributes.merge!(aria_invalid: "true") if errors.any?
      yield
      if errors.any?
        small { "#{field_name.to_s.capitalize} #{errors.to_sentence}" }
      end
    end
  end

  def permit(params)
    params.require(@model.model_name.param_key).permit(*@fields)
  end
end
