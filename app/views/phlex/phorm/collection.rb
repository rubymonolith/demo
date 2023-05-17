module Phlex::Phorm
  class Collection < Field
    include Enumerable

    def values
      Enumerator.new do |y|
        @value.each.with_index do |value, index|
          y << field(index, value: value)
        end
      end
    end

    def to_h
      @children.map do |child|
        child.children.any? ? child.to_h : child.value
      end
    end

    def each(&)
      values.each(&)
    end
  end
end