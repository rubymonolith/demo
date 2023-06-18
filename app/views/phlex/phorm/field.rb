module Phlex::Phorm
  class Field
    attr_accessor :parameter

    include Enumerable

    def each(&)
      parameter.each { |parameter| build_field parameter }
    end

    def initialize(parameter)
      @parameter = parameter
    end

    def field(key = nil, *args, **kwargs, &)
      parameter = if key.is_a?(Parameter)
        key
      elsif key.present?
        @parameter.field(key, *args, **kwargs)
      else
        @parameter.field(*args, **kwargs)
      end

      build_field parameter, &
    end

    def collection(key = nil, *args, **kwargs, &)
      collection = key.is_a?(Collection) ? key : @parameter.collection(key, *args, **kwargs)
      build_field collection, &
    end

    def fields(*keys, **kwargs)
      keys.map { |key| field(key, **kwargs) }
    end

    private

    def build_field(parameter)
      self.class.new(parameter).tap do |field|
        yield field if block_given?
      end
    end
  end
end
