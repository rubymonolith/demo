class Phlex::Phorm < Phlex::HTML
  attr_reader :model

  delegate :field, :fields_for, to: :@fields

  def initialize(model, action: nil, method: nil)
    @model = model
    @action = action
    @method = method
    @fields = Fields.from_model model
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

  class Fields
    def initialize(keys: [], object: nil)
      @keys = Array(keys)
      @object = object
      @permitted_fields = Set.new
      @fields_for = []
    end

    def field(attribute, permitted: true, **attributes)
      permit_field(attribute) if permitted
      Field.new namespace: @keys, object: @object, attribute: attribute, **attributes
    end

    def fields_for(*namespace, permitted: true)
      *keys, object = namespace
      attribute = keys.first
      permit_field(attribute) if permitted

      self.class.new(keys: @keys + keys, object: object).tap do |fields|
        yield fields if block_given?
        @fields_for << fields
      end
    end

    def self.from_model(model, **kwargs)
      new object: model, keys: model.model_name.param_key
    end

    def permit(params)
    end

    private

    def permit_field(attribute)
      @permitted_fields << attribute.to_sym
    end
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
end
