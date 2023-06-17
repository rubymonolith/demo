# frozen_string_literal: true

class ApplicationForm < Phlex::Phorm::Form
  include Phlex::Phorm::Components

  class LabeledInputComponent < FieldComponent
    def template
      label { field.key.to_s.titleize }
      input(id: field.id)
    end
  end

  class Field < Field
    def labeled_input(**attributes)
      LabeledInputComponent.new(field: self, attributes: attributes)
    end
  end

  def labeled(component)
    render component.field.label
    render component
  end
end
