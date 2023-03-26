class BlogsController < ApplicationController
  resources :blogs, from: :current_user

  class Show < ApplicationView
    attr_writer :blog, :current_user

    def template(&)
      h1 { @blog.title }
      a(href: new_blog_post_path(@blog)) { "Create Post" }
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
