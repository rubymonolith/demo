# frozen_string_literal: true

class ApplicationForm < Phlex::Phorm::Form
  include Phlex::Phorm::Components

  def labeled(component)
    render component.field.label
    render component
  end
end
