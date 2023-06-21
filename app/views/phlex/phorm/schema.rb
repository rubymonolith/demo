module Phlex::Phorm
  class Schema
    include Enumerable

    attr_accessor :key

    def initialize(key, permit: true)
      @key = key
      @permit = permit
      @children = Set.new
      yield self if block_given?
    end

    def eql?(other)
      other.is_a?(Schema) && @key.eql?(other.key)
    end

    def hash
      @key.hash
    end

    def each(&)
      @children.each(&)
    end

    def permitted?
      !!@permit
    end

    def permit(...)
      self.class.new(...).tap do |child|
        @children.add child
        yield child if block_given?
      end
    end

    def keys
      select(&:permitted?).map do |child|
        if child.any?
          { child.key => child.keys }
        else
          child.key
        end
      end
    end
  end
end
