module Assignable
  extend ActiveSupport::Concern

  included do
    class_attribute :model, :parent_model, :context_method_name

    before_action :assign_collection
    before_action :assign_member
  end

  def assign_collection
    instance_variable_set "@#{model.model_name.plural}", model_scope
  end

  def model_scope
    if has_assignable_context?
      assignable_context.association(model.model_name.collection).scope
    else
      model.scope_for_association
    end
  end

  def assign_member
    instance_variable_set "@#{model.model_name.singular}", model_instance
  end

  def model_instance
    if member?
      model_scope.find(params.fetch(param_key))
    else
      model_scope.build
    end
  end

  def member?
    params.key? param_key
  end

  def param_key
    :id
  end

  def assignable_context
    self.send self.class.context_method_name
  end

  def has_assignable_context?
    if self.class.context_method_name
      self.respond_to? self.class.context_method_name
    end
  end

  class_methods do
    def assign(scope, through: nil, from: nil)
      self.model = Assignable.find_scope scope
      self.parent_model = Assignable.find_scope through
      self.context_method_name = from
    end
  end

  def self.find_scope(name)
    name.to_s.singularize.camelize.constantize if name
  end
end
