class Blogs::PostsController < ApplicationController
  resources :posts, through: :blogs, from: :current_user
  before_action :assign_user, only: %i[new create]

  class New < ApplicationView
    attr_accessor :current_user, :blog, :post

    def template(&)
      h1 { "Create a new post for #{@blog.title}" }
      render PostsController::Form.new(@post)
    end
  end

  private

  def assign_user
    @post.user = current_user
  end
end
