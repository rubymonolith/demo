class Users::SessionsController < ApplicationController
  def create
    session[:user_id] = params.require(:user).permit(:id)
    redirect_to root_url
  end
end
