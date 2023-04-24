module Batchable
  extend ActiveSupport::Concern

  protected

  def method_for_action(action_name)
    routable_batch_action? ? batch_action : super
  end

  def batch_action
    params.dig("batch", "action")
  end

  def routable_batch_action?
    self.class.action_methods.include? batch_action
  end
end
