class Blogs::PostsController < ApplicationController
  resources :posts, through: :blogs, from: :current_user
  before_action :assign_user, only: %i[new create]

  class New < ApplicationView
    attr_accessor :current_user, :blog, :post
    turbo method: :morph do
      stream_from @blog, @blog.user
    end

    def title = "Create a new post"
    def subtitle = show(@blog, :title)

    def template(&)
      render PostsController::Form.new(@post)
    end
  end

  private

  def assign_user
    @post.user = current_user
  end
end
