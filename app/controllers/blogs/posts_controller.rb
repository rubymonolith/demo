class Blogs::PostsController < ApplicationController
  resources :posts, through: :blogs, from: :current_user

  class Form < ApplicationForm
    def template
      field :title
      field :content
      submit
    end
  end

  class New < ApplicationView
    attr_accessor :current_user, :blog, :post

    def template(&)
      h1 { "Create a new post for #{@blog.title}" }
      render Form.new(@post)
    end
  end
end
