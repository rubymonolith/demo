class Blogs::Batch::PostsController < ApplicationController
  before_action :assign_batch
  assign :posts, through: :blogs, from: :current_user
  # TODO: How can I compose `assign :posts, ... with `resources`?

  include Batchable

  class ItemForm < ApplicationForm
  end

  class Index < ApplicationView
    attr_accessor :posts, :blog, :current_user, :batch

    def title = "#{@blog.title} Posts"
    def subtitle = "Select posts"

    def template(&)
      render ApplicationForm.new(@batch, url: url_for) do |form|
        render TableComponent.new(items: @batch) do |table|
          table.column do |column|
            column.item do |selection|
              input(type: "checkbox", value: selection.selected, name: "batch[items][#{selection.id}][selected]")
              # render ItemForm.new selection
            end
          end
          table.column("Title")         { show(_1.item, :title) }
          table.column("Author")        { show(_1.item.user, :name) }
          table.column("Status")        { "Not Published" }
          table.column("Publish Date")  { _1.item.publish_at&.to_formatted_s(:long) }
        end

        nav do
          ul do
            li do
              form.button_field(:action, value: :delete) { "Delete" }
            end
            li do
              form.button_field(:action, value: :publish) { "Publish" }
            end
          end
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
