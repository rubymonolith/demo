module Resource
  extend ActiveSupport::Concern

  included do
    class_attribute :resource_name
    before_action :assign_resource_instance_variables, if: :is_resource?
  end

  class_methods do
    def resources(name, ...)
      self.resource_name = name.to_s.singularize
      assign(name, ...)
    end
  end

  def create
    @resource.assign_attributes phlex_form(:new).permit(params)

    if @resource.save
      redirect_to @resource
    else
      # Maybe I should just render it with a string? That way
      # if there's an error I can just show the darn thing; if there's
      # not an error, then I can simply redirect. I'd somehow have to
      # deferr rendering.
      render phlex_action(:new), status: :unprocessable_entity
    end
  end

  def update
    @resource.assign_attributes phlex_form(:edit).permit(params)

    if @resource.save
      redirect_to @resource
    else
      # Maybe I should just render it with a string? That way
      # if there's an error I can just show the darn thing; if there's
      # not an error, then I can simply redirect. I'd somehow have to
      # deferr rendering.
      render phlex_action(:new), status: :unprocessable_entity
    end
  end

  def destroy
    @resource.destroy
    redirect_to destroyed_url
  end

  protected

  def destroyed_url
    url_for(action: :index)
  end

  def created_url
    @resource
  end
  alias :updated_url :created_url

  private

  def unrendered_phlex_action(action)
    phlex_action(action).tap do |view|
      view.call(Phlex::BlackHole, view_context: view_context)
    end
  end

  def phlex_form(action)
    unrendered_phlex_action(action).forms.first
  end

  def assign_resource_instance_variables
    @resource = instance_variable_get("@#{resource_name.singularize}")
    @resources = instance_variable_get("@#{resource_name.pluralize}")
  end

  def is_resource?
    self.class.resource_name.present?
  end
end
