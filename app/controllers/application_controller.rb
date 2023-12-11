class ApplicationController < ActionController::Base
  include Assignable
  include Superview::Actions
  include Resource

  layout false

  def current_user
    @current_user ||= User.find_or_create_by!(email: "somebody@example.com", name: "Somebody")
  end
end
