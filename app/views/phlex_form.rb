class PhlexForm < Phlex::HTML
  attr_reader :fields, :model

  def initialize(model)
    @model = model
    @fields = Set.new
  end

  # Joel does this in a way with slightly less LOC.
  def self.input_field(method_name, type:)
    define_method method_name do |field, **attributes|
      input_field(field: field, type: type, **attributes)
    end
  end

  def around_template(&)
    form action: url, method: "post" do
      authenticity_token_field
      _method_field
      super
    end
  end

  def template(&block)
    yield_content(&block)
  end

  def authenticity_token_field
    input(
      name: "authenticity_token",
      type: "hidden",
      value: helpers.form_authenticity_token
    )
  end

  def input_field(field:, value: nil, type: "text", **attributes)
    @fields << field
    input(
      name: field_name(field),
      type: type,
      value: value || model_value(field),
      **attributes
    )
  end

  def _method_field
    input(
      name: "_method",
      type: :hidden,
      value: _method_field_value)
  end

  def _method_field_value
   @model.persisted? ? "patch" : "post"
  end

  def submit(value = submit_value)
    input(
      name: "commit",
      type: "submit",
      value: value
    )
  end

  def submit_value
    "#{action.to_s.capitalize} #{@model.model_name}"
  end

  def action
    @model.persisted? ? :update : :create
  end

  def url
    helpers.url_for(action: action)
  end

  def field_name(*field)
    helpers.field_name(ActiveModel::Naming.param_key(@model.class), *field)
  end

  def model_value(field)
    @model.attributes.fetch(field.to_s)
  end

  ## Less sure about this stuff...
  def infer_type(name)
    return "email" if name == "email"

    case model_value(name)
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

  input_field :url_field, type: "url"
  input_field :text_field, type: "text"
  input_field :date_field, type: "date"
  input_field :time_field, type: "time"
  input_field :week_field, type: "week"
  input_field :month_field, type: "month"
  input_field :email_field, type: "email"
  input_field :color_field, type: "color"
  input_field :hidden_field, type: "hidden"
  input_field :search_field, type: "search"
  input_field :password_field, type: "password"
  input_field :telephone_field, type: "tel"
  input_field :datetime_local_field, type: "datetime-local"
end
