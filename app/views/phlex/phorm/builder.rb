module Phlex::Phorm
  class Builder
    def initialize(field: Phlex::Phorms::Field, namespace: Phlex::Phorms::Namespace, collection: Phlex::Phorms::Collection)
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

    def self.from(object)
      new field: object::Field, namespace: object::Namespace, collection: object::Collection
    end
  end
end
