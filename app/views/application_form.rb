# frozen_string_literal: true

class ApplicationForm < Phlex::Phorm::Form
  include Phlex::Phorm::Components

  # class Field < Field
  #   class LabelField < Phlex::Phorm::Components::FieldComponent
  #     def template
  #       label(**attributes) { strong { dom.title } }
  #     end
  #   end

  #   def label(**attributes)
  #     LabelField.new(parameter, attributes: attributes)
  #   end
  # end

  def labeled(component)
    render View.new(component.namespace).label
    render component
  end
end
