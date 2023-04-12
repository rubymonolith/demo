class Users::BlogsController < ApplicationController
  resources :blogs, from: :current_user

  class New < ApplicationView
    attr_writer :blog

    def title = "Create blog"
    def subtitle = "You'll be writing awesome stuff in no time"

    def template
      render BlogsController::Form.new(@blog)
    end
  end

  class Index < ApplicationView
    attr_writer :blogs, :current_user

    def title = "#{@current_user.name}'s Blogs"

    def template(&)
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
