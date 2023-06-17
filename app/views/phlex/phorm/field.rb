module Phlex::Phorm
  class Field
    attr_accessor :parameter

    def initialize(parameter)
      @parameter = parameter
    end

    def field(*args, **kwargs, &)
      self.class.new(@parameter.field(*args, **kwargs)).tap do |components|
        yield components if block_given?
      end
    end

    def fields(*keys, **kwargs)
      keys.map { |key| field(key, **kwargs) }
    end

    def collection(*args, **kwargs, &)
      self.class.new(@parameter.collection(*args, **kwargs)).tap do |components|
        yield components if block_given?
      end
    end
  end
end