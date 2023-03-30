class PostsController < ApplicationController
  resources :posts, from: :current_user

  class Form < ApplicationForm
    def template
      field :title
      field :content
      submit
    end
  end

  class Index < ApplicationView
    attr_writer :posts

    def template
      h1 { "My Posts" }
      table do
        thead do
          th { "Post" }
          th { "Blog" }
        end
        tbody do
          @posts.each do |post|
            tr do
              th { show(post, :title) }
              th { show(post.blog, :title) }
            end
          end
        end
      end
    end
  end

  class Show < ApplicationView
    attr_writer :post

    def template
      hgroup do
        h1 { @post.title }
        h2 { show(@post.blog, :title) }
      end
      article { @post.content }
      nav do
        edit(@post, role: "button")
        delete(@post)
      end
    end
  end

  class Edit < ApplicationView
    attr_writer :post

    def template
      h1 { @post.title }
      render Form.new(@post)
    end
  end

  private

  def destroyed_url
    @post.blog
  end
end
