# frozen_string_literal: true

class ApplicationForm < Superform::Form
  class LabelField < Superform::Components::FieldComponent
    def template
      label(**attributes) { strong { dom.title } }
    end
  end

  class Field < Field
    def label(**attributes)
      LabelField.new(self, attributes: attributes)
    end
  end

  def labeled(component)
    render component.namespace.label
    render component
  end
end
