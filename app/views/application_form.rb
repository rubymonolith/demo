# frozen_string_literal: true

class ApplicationForm < Superform::Rails::Form
  class LabelField < Superform::Rails::Components::LabelComponent
    def template(&content)
      content ||= Proc.new { field.title }
      label(**attributes) { strong(&content) }
    end
  end

  class Field < Field
    def label(**attributes)
      LabelField.new(self, attributes: attributes)
    end
  end

  # def field(name)
  #   if reflection = @model.class.reflect_on_association(name)
  #     name = reflection.foreign_key
  #   end
  #   super(name)
  # end

  def labeled(component, &)
    render component.field.label
    render component, &
  end
end
