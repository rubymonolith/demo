class BlogsController < ApplicationController
  resources :blogs, from: :current_user

  class Form < ApplicationForm
    def template
      labeled field(:title).input

      submit
    end
  end

  class Show < ApplicationView
    attr_writer :blog, :current_user
    turbo method: :morph do
      stream_from @blog, @current_user, @blog.posts
    end

    def title = @blog.title
    def subtitle
      plain "Owned and operated by "
      show(@blog.user, :name)
    end

    def template(&)
      render TableComponent.new(items: @blog.posts) do |table|
        table.column("Title")         { show(_1, :title) }
        table.column("Author")        { show(_1.user, :name) }
        table.column("Status")        { "Not Published" }
        table.column("Publish Date")  { _1.publish_at&.to_formatted_s(:long) }
      end
      nav do
        create(@blog.posts, role: "button")
        show(blog_batch_posts_path(@blog)){ "Select Posts" }
        edit(@blog)
        delete(@blog)
      end
    end
  end

  class Edit < Show
    def template
      render Form.new(@blog)
    end
  end

  class Index < ApplicationView
    attr_accessor :blogs, :current_user

    turbo method: :morph do
      stream_from @current_user, @blogs
    end

    def title = "Blogs"
    def subtitle = "Looks like #{helpers.pluralize @blogs.count, "blog"} have been created"

    def template
      render TableComponent.new(items: @blogs) do |table|
        table.column("Title") { show(_1, :title) }
        table.column("Owner") { show(_1.user, :name) }
      end
      create(@current_user.blogs, role: "button")
    end
  end

  def created_url
    @blog
  end
end
