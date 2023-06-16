module Phlex::Phorm
  class DOM
    include ActionView::Helpers::FormTagHelper

    def initialize(field)
      @field = field
    end

    def name
      return @field.key.to_s if root?
      field_name *name_keys
    end

    def id
      return @field.key.to_s if root?
      field_id *id_keys
    end

    private

    def id_keys
      lineage.map(&:key)
    end

    def name_keys
      lineage.map { |field| field.key unless field.parent.is_a? Collection }
    end

    def lineage
      parents.to_a.reverse.append(@field)
    end

    def parents
      field = @field
      Enumerator.new do |y|
        while field = field.parent
          y << field
        end
      end
    end

    def root?
      !@field.parent
    end
  end
end
