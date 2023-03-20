class Users::BlogsController < ApplicationController
  include Assignable
  include Phlexable

  assign :blogs, from: :current_user

  class New < ApplicationView
    attr_accessor :current_user, :blogs

    def template(&)
      h1 { "Create a new blog for #{@current_user.name}" }
      section { @blog.inspect }
    end
  end

  class Index < ApplicationView
    attr_writer :blogs, :current_user

    def template(&)
      h1 { "#{@current_user.name}'s Blogs" }
      section do
        ul {
          @blogs.each { |blog|
            li { helpers.link_to(blog.title, blog) }
          }
        }
        a(href: new_user_path) { "Create user" }
      end
    end
  end

  def new
    render phlex
  end

  def index
    render phlex
  end
end
