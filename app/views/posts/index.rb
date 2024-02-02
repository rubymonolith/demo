module Posts
  class Index < ApplicationView
    attr_writer :posts, :current_user

    turbo method: :morph do
      stream_from @posts, @current_user
    end

    def title = "#{@current_user.name}'s Posts"

    def template
      render TableComponent.new(items: @posts) do |table|
        table.column("Title") { show(_1, :title) }
        table.column do |column|
          # Titles might not always be text, so we need to handle rendering
          # Phlex markup within.
          column.title do
            link_to(user_blogs_path(@current_user)) { "Blogs" }
          end
          column.item { show(_1.blog, :title) }
        end
      end
    end
  end
end