# frozen_string_literal: true

class ApplicationForm < Phlex::Phorm
  def self.register_polymorphic_element(tag)
  end

  def input(object = nil, **attributes, &content)
    component = object.send(:input, **attributes) if object and object.respond_to? :input

    if component
      render component
    else
      super
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
