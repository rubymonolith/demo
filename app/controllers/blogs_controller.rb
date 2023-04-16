class BlogsController < ApplicationController
  resources :blogs, from: :current_user

  class Show < ApplicationView
    attr_writer :blog, :current_user

    def title = @blog.title
    def subtitle
      text "Owned and operated by "
      show(@blog.user, :name)
    end

    def template(&)
      render TableComponent.new(items: @blog.posts) do |table|
        table.column("Title")         { show(_1, :title) }
        table.column("Author")        { show(_1.user, :name) }
        table.column("Status")        { "Not Published" }
        table.column("Publish Date")  { _1.publish_at&.to_formatted_s(:long) }
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
