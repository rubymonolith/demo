module Phlex::Phorm
  class Collection < Parameter
    include Enumerable

    def initialize(...)
      @index = 0
      super(...)
    end

    def field(**kwargs, &)
      super(@index, **kwargs, &)
    ensure
      @index += 1
    end

    def values
      Enumerator.new do |y|
        @value.each do |value|
          y << field(value: value)
        end
      end
    end

    def each(&)
      values.each(&)
    end

    def to_h
      @children.map(&:to_h)
    end
  end
end
