class Phlex::Phorm < Phlex::HTML
  attr_reader :fields, :model

  def initialize(model, action: nil, method: nil)
    @model = model
    @action = action
    @method = method
    @fields = Set.new
  end

  def around_template(&)
    form action: form_action, method: form_method do
      authenticity_token_field
      _method_field
      super
    end
  end

  def template(&block)
    yield_content(&block)
  end

  def submit(value = submit_value)
    input(
      name: "commit",
      type: "submit",
      value: value
    )
  end

  def field(attribute)
    Field.new model: @model, attribute: attribute
  end

  protected

  def authenticity_token_field
    input(
      name: "authenticity_token",
      type: "hidden",
      value: helpers.form_authenticity_token
    )
  end

  def _method_field
    input(
      name: "_method",
      type: "hidden",
      value: _method_field_value
    )
  end

  def _method_field_value
    @method || @model.persisted? ? "patch" : "post"
  end

  def submit_value
    "#{resource_action.to_s.capitalize} #{@model.model_name}"
  end

  def resource_action
    @model.persisted? ? :update : :create
  end

  def form_action
    @action ||= helpers.url_for(action: resource_action)
  end

  def form_method
    @method.to_s.downcase == "get" ? "get" : "post"
  end

  def self.polymorphic_tag(html_tag)
    attributes_method = "#{html_tag}_attributes"
    content_method = "#{html_tag}_content"

    define_method html_tag do |object = nil, **attributes, &content|
      if object.respond_to? attributes_method
        attributes = object.send(attributes_method).merge(attributes)
      end

      if object.respond_to? content_method
        # TODO: Ideally I could pass just the method or call to_proc on it. Joel said he's going
        # to add support for this, so see where thats at.
        content ||= Proc.new { object.method(content_method).call }
      end

      super(**attributes, &content)
    end
  end

  polymorphic_tag :textarea
  polymorphic_tag :input
  polymorphic_tag :label
  polymorphic_tag :button
end