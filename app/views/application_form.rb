# frozen_string_literal: true

class ApplicationForm < Phlex::Phorm::Form
  include Phlex::Phorm::Components

  field :input, component: InputComponent
  field :textarea, component: TextareaComponent
  field :label, component: LabelComponent
  field :button, component: ButtonComponent

  class LabeledInputComponent < FieldComponent
    def template
      label { field.name.to_s.titleize }
      input(id: field_id)
    end
  end

  field :labled_input, component: LabeledInputComponent

  def labeled(component)
    render component.field.label
    render component
  end
end
