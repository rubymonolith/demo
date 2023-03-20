class Blogs::PostsController < ApplicationController
  include Assignable
  include Phlexable

  assign :posts, through: :blogs, from: :current_user

  class New < ApplicationView
    attr_accessor :current_user, :post, :blog

    def template(&)
      h1 { "Create a new post for #{@blog.name}" }
      section { @post.inspect }
    end
  end

  def new
    render phlex
  end
end
