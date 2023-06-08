module Phlex::Phorm::Components
  class TagComponent < ApplicationComponent
    attr_reader :field

    delegate \
        :name,
        :id,
        :title,
        :value,
      to: :@dom,
      prefix: :field

    def initialize(field:, tag: self.class.tag, attributes: {})
      @field = field
      @tag = tag
      @attributes = attributes
      @dom = Phlex::Phorm::DOM.new(@field)
    end

    protected

    def attributes
      attribute_methods.each_with_object(Hash.new) do |attribute, hash|
        hash[attribute] = self.send(attribute)
      end.merge(@attributes)
    end

    def around_template(&)
      tag(**attributes) { super }
    end

    def template
      nil
    end

    def self.tag(name = nil)
      @tag ||= name
    end

    protected

    def tag(...)
      self.send(@tag, ...)
    end

    private

    def attribute_methods
      public_methods(false) - [ :call, :template, :content, :attributes, :initialize ]
    end
  end

  class LabelComponent < TagComponent
    tag :label

    def template = plain field_title

    def for = field_id
    def name = "hi"
  end

  class ButtonComponent < TagComponent
    tag :button

    def template = plain field_value.to_s.titleize

    def id = field_id
    def name = field_name
    def value = field_value
  end

  class InputComponent < TagComponent
    tag :input

    def id = field_id
    def name = field_name
    def value = field_value
    def type
      case field_value
      when URI
        "url"
      when Integer
        "number"
      when Date, DateTime
        "date"
      when Time
        "time"
      else
        "text"
      end
    end
  end

  class TextareaComponent < TagComponent
    tag :textarea

    def template = plain field_value

    def id = field_id
    def name = field_name
  end
end