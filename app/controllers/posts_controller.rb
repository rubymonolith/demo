class PostsController < ApplicationController
  resources :posts, from: :current_user

  # Demonstration of including views that have been moved
  # from the controller into their own files. This makes sense
  # if your views need to be shared between multiple controllers
  # or if your project prefers to have views as their own files.
  include Posts

  private

  def destroyed_url
    @post.blog
  end
end
