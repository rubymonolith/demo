module Batchable
  extend ActiveSupport::Concern

  included do
    before_action :assign_selection
  end

  class Selection
    include ActiveModel::API
    attr_accessor :selected, :action, :scope

    def selected
      @selected ||= []
    end

    def selected?(item = nil)
      if item
        selected.include? item.to_s
      else
        selected.any?
      end
    end

    def select_none
      self.selected = []
    end

    def select_all
      self.selected = items.pluck(:id).map(&:to_s)
    end

    def selected_items
      items.where(id: selected)
    end

    def items
      @scope
    end

    def self.action_param_key
      :action
    end

    def self.permit(params)
      params.fetch(model_name.param_key, {}).permit(:action, selected: [])
    end

    def self.action(params)
      params.dig model_name.param_key, action_param_key
    end
  end

  protected

  def assign_selection
    @selection = Selection.new(scope: scope, **permitted_batch_params)
  end

  def permitted_batch_params
    Selection.permit params
  end

  def method_for_action(action_name)
    routable_batch_action? ? Selection.action(params) : super
  end

  def routable_batch_action?
    self.class.action_methods.include? Selection.action(params)
  end
end
