class ApplicationController < ActionController::Base
  include Assignable
  include Phlexable

  def current_user
    @current_user ||= User.first
  end
end
