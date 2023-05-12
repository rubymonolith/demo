# frozen_string_literal: true

class ApplicationForm < Phlex::Phorm
  def form_row(field_name, **attributes)
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

  def input_field(field_name, **attributes)
    form_row(field_name) do
      render field(field_name).label
      render field(field_name).input
    end
  end

  def textarea_field(field_name, **attributes)
    form_row(field_name) do
      render field(field_name).label
      render field(field_name).textarea(**attributes)
    end
  end
end
