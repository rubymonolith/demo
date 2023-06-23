module Superform
  class Field
    attr_accessor :value, :key, :parent

    def initialize(key, value: nil, parent:)
      @key = key
      @parent = parent
      self.assign value
    end

    def assign(value)
      @value = value
    end

    def serialize
      @value
    end
  end
end
