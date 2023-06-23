module Superform
  class DOM
    include ActionView::Helpers::FormTagHelper

    def initialize(namespace)
      @namespace = namespace
    end

    def name
      return @namespace.key.to_s if root?
      field_name *name_keys
    end

    def id
      return @namespace.key.to_s if root?
      field_id *id_keys
    end

    def key
      @namespace.key.to_s
    end

    def value
      @namespace.value.to_s
    end

    def title
      key.titleize
    end

    private

    def id_keys
      lineage.map(&:key)
    end

    def name_keys
      lineage.map { |namespace| namespace.key unless namespace.parent.is_a? Collection }
    end

    def lineage
      parents.to_a.reverse.append(@namespace)
    end

    def parents
      namespace = @namespace
      Enumerator.new do |y|
        while namespace = namespace.parent
          y << namespace
        end
      end
    end

    def root?
      !@namespace.parent
    end
  end
end
