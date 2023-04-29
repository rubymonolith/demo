module Batchable
  extend ActiveSupport::Concern

  class Batch
    include Enumerable

    include ActiveModel::API
    attr_accessor :items, :scope, :action

    class Item
      include ActiveModel::API
      attr_accessor :selected, :item

      delegate :id, to: :item
    end

    def selection
      @scope.where(id: ids)
    end

    def each
      @scope.each do |item|
        yield Item.new(item: item, selected: false)
      end
    end

    def self.action_param_key
      "action"
    end

    private

    def selected_ids
      raise "hell"
    end
  end

  protected

  def assign_batch
    @batch = Batch.new(scope: @blog.posts, **permitted_batch_params)
  end

  def permitted_batch_params
    params.fetch(Batch.model_name.param_key, {}).permit(:action, items: [:selected])
  end

  def method_for_action(action_name)
    routable_batch_action? ? batch_action : super
  end

  def batch_action
    params.dig Batch.model_name.param_key, Batch.action_param_key
  end

  def routable_batch_action?
    self.class.action_methods.include? batch_action
  end
end
