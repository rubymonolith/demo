module Superform
  class Builder
    def initialize(field: Superform::Field, namespace: Superform::Namespace, collection: Superform::Collection)
      @field = field
      @namespace = namespace
      @collection = collection
    end

    def field(*args, **kwargs, &)
      @field.new(*args, **kwargs, &)
    end

    def namespace(*args, **kwargs, &)
      @namespace.new(*args, builder: self, **kwargs, &)
    end

    def collection(*args, **kwargs, &)
      @collection.new(*args, builder: self, **kwargs, &)
    end

    def self.from(constant)
      new field: constant::Field, namespace: constant::Namespace, collection: constant::Collection
    end
  end
end
