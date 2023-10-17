class ApplicationController < ActionController::Base
  include Assignable
  include Superview::Actions
  include Resource

  layout false

  def current_user
    @current_user ||= User.first
  end
end
