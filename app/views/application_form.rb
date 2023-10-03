# frozen_string_literal: true

class ApplicationForm < Superform::Rails::Form
  class LabelField < Superform::Rails::Components::LabelComponent
    def template
      label(**attributes) { strong { field.title } }
    end
  end

  class SelectField < Superform::Rails::Components::FieldComponent
    def template(&options)
      select(**attributes, &options)
    end

    def options(collection)
      collection.each do |id, value|
        option(value: id, selected: id == field.value) { value }
      end
    end

    def blank_option
      option(selected: field.value.nil?)
    end
  end


  class Field < Field
    def label(**attributes)
      LabelField.new(self, attributes: attributes)
    end

    def select(**attributes, &)
      SelectField.new(self, attributes: attributes, &)
    end
  end

  def labeled(component)
    render component.field.label
    render component
  end
end
