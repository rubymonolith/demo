class PostsController < ApplicationController
  resources :posts, from: :current_user

  class Form < ApplicationForm
    def template
      labeled(field(:blog_id).select do |s|
        Blog.all.each do |blog|
          option(value: blog.id, selected: blog.id == s.field.value) { blog.title }
        end
        option(selected: s.field.value.nil?)
      end)
      labeled field(:title).input.focus
      labeled field(:publish_at).input
      labeled field(:content).textarea(rows: 6)

      submit
    end
  end

  class New < ApplicationView
    def title = "New Post"

    def template
      render Form.new(Post.new)
    end
  end

  class Index < ApplicationView
    attr_writer :posts, :current_user

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

  class Show < ApplicationView
    attr_writer :post

    def title = @post.title
    def subtitle = show(@post.blog, :title)

    def template
      table do
        tbody do
          tr do
            th { "Status" }
            td { @post.status }
          end
          tr do
            th { "Publish at" }
            td { @post.publish_at&.to_formatted_s(:long) }
          end
          tr do
            th { "Content" }
            td do
              article { @post.content }
            end
          end
        end
      end
      nav do
        edit(@post, role: "button")
        delete(@post)
      end
    end
  end

  class Edit < ApplicationView
    attr_writer :post

    def title = @post.title
    def subtitle = show(@post.blog, :title)

    def template
      render Form.new(@post)
    end
  end

  private

  def destroyed_url
    @post.blog
  end
end
