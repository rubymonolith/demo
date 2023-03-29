class BlogsController < ApplicationController
  resources :blogs, from: :current_user

  class Show < ApplicationView
    attr_writer :blog, :current_user

    def template(&)
      h1 { @blog.title }
      p { "Owned and operated by #{@blog.user.name}"}
      ol do
        @blog.posts.each do |post|
          li { show(@post, :title) }
        end
      end
      create(@blog.posts, role: "button")
    end
  end

  class Form < ApplicationForm
    def template
      field :title
      submit
    end
  end

  def created_url
    @blog
  end
end
