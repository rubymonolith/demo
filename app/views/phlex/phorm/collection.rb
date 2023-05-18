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
        # A child might have a nil key set, which is a field that
        # is a blank collection.
        child.children.find(&:key) ? child.to_h : child.value
      end
    end

    def each(&)
      values.each(&)
    end
  end
end
