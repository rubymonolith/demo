class Blogs::PostsController < ApplicationController
  include Assignable
  include Phlexable

  assign :posts, through: :blogs, from: :current_user

  class New < ApplicationView
    attr_accessor :current_user, :blog, :post

    def template(&)
      h1 { "Create a new post for #{@blog.title}" }
      section { @post.inspect }
    end
  end
end
