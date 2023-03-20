class BlogsController < ApplicationController
  include Assignable
  include Phlexable

  assign :blogs, from: :current_user

  class Show < ApplicationView
    attr_writer :blog, :current_user

    def template(&)
      h1 { @blog.title }
      a(href: new_blog_post_path(@blog)) { "Create Post" }
    end
  end

  def show
    render phlex
  end
end
