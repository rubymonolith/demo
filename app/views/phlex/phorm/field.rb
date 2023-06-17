module Phlex::Phorm
  class Field
    attr_accessor :parameter

    def initialize(parameter)
      @parameter = parameter
    end

    def field(key = nil, *args, **kwargs, &)
      parameter = key.is_a?(Parameter) ? key : @parameter.field(key, *args, **kwargs)
      build_field parameter, &
    end

    def collection(key = nil, *args, **kwargs, &)
      parameter = key.is_a?(Collection) ? key : @parameter.collection(key, *args, **kwargs)
      build_field parameter, &
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
