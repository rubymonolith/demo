module Phlex::Phorm
  class Collection < Field
    include Enumerable

    def initialize(...)
      @index = 0
      super(...)
    end

    def values
      Enumerator.new do |y|
        @value.each do |value|
          y << field(value: value)
        end
      end
    end

    def field(**kwargs, &block)
      super(@index, **kwargs, &block).tap do
        @index += 1
      end
    end
    alias :append :field

    def to_h
      @children.map(&:to_h)
    end

    def each(&)
      values.each(&)
    end
  end
end
