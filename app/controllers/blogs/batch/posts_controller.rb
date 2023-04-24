class Blogs::Batch::PostsController < ApplicationController
  resources :posts, through: :blogs, from: :current_user

  include Batchable

  class Batch
    include ActiveModel::API
    attr_accessor :ids, :scope
  end

  class Index < ApplicationView
    attr_accessor :posts, :blog, :current_user

    def title = "#{@blog.title} Posts"
    def subtitle = "Select posts"

    def template(&)
      form url: blog_batch_posts_path(@blog), method: :post do
        list(@blog.posts) do |post|
          show(post, :title)
        end
        nav do
          button(value: :delete, name: "batch[action]") { "Delete" }
          button(value: :publish, name: "batch[action]") { "Publish" }
        end
      end
    end
  end

  def delete
    @posts.delete_all
  end

  def publish
    @blog.posts.update(publish_at: Time.current)
  end
end
