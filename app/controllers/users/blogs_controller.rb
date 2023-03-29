class Users::BlogsController < ApplicationController
  resources :blogs, from: :current_user

  class New < ApplicationView
    attr_writer :blog

    def template
      h1 { "Create a new blog" }
      render BlogsController::Form.new(@blog)
    end
  end

  class Index < ApplicationView
    attr_writer :blogs, :current_user

    def template(&)
      h1 { "#{@current_user.name}'s Blogs" }
      section do
        ul {
          @blogs.each { |blog|
            li { show(blog, :title) }
          }
        }
        create(@current_user.blogs, role: "button")
      end
    end
  end
end
