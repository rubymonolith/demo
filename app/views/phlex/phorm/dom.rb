module Phlex::Phorm
  class DOM
    include ActionView::Helpers::FormTagHelper

    def initialize(field)
      @field = field
    end

    def name
      field_name *name_keys
    end

    def id
      field_id *id_keys
    end

    def id_keys
      parents.map(&:key).reverse.append(@field.key)
    end

    def name_keys
      parents.map(&:name).reverse.append(@field.name)
    end

    private

    def parents
      field = @field
      Enumerator.new do |y|
        while field = field.parent
          y << field
        end
      end
    end
  end
end
