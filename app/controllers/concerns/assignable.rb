module Assignable
  extend ActiveSupport::Concern

  included do
    class_attribute :model, :parent_model, :context_method_name

    before_action :assign_parent_collection, if: :has_parent_model?
    before_action :assign_parent_member, if: :has_parent_model?
    before_action :assign_collection
    before_action :assign_member
  end

  def assign_collection
    instance_variable_set "@#{model.model_name.plural}", model_scope
  end

  def assign_parent_collection
    instance_variable_set "@#{parent_model.model_name.plural}", parent_model_scope
  end

  def model_scope
    if has_parent_model?
      parent_model_instance.association(model.model_name.collection)
    elsif has_assignable_context?
      assignable_context.association(model.model_name.collection).scope
    else
      model.scope_for_association
    end
  end

  def parent_model_scope
    if has_assignable_context?
      assignable_context.association(parent_model.model_name.collection)
    else
      parent_model.scope_for_association
    end
  end

  def parent_model_instance
    parent_model_scope.find(params.fetch(parent_model_param_key))
  end

  def assign_parent_member
    instance_variable_set "@#{parent_model.model_name.singular}", parent_model_instance
  end

  def has_parent_model?
    parent_model.present?
  end

  def assign_member
    instance_variable_set "@#{model.model_name.singular}", model_instance
  end

  def model_instance
    if member?
      model_scope.find params.fetch(model_param_key)
    else
      model_scope.build.tap do |post|
        # # Blog is a reflection of User
        # # Get the name of the `user` association.
        # parent_from_association = parent_model_scope.reflection.inverse_of

        # if model.reflect_on_association(parent_from_association.name)
        #   similar_association = model.association parent_from_association.name
        #   # Now let's see if that association exists on the current_model ..
        #   #
        #   # This isn't setting the foreign key ... errrggggg.
        #   raise 'hell'

        #   # post.association(association_name).target = parent_model_scope.owner
        # end
      end
    end
  end

  def member?
    params.key? model_param_key
  end

  def model_param_key
    :id
  end

  def parent_model_param_key
    "#{parent_model.model_name.singular}_id".to_sym
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
