class Blogs::Batch::PostsController < ApplicationController
  assign :posts, through: :blogs, from: :current_user
  # TODO: How can I compose `assign :posts, ... with `resources`?

  include Batchable

  class Index < ApplicationView
    attr_accessor :posts, :blog, :current_user, :batch

    def title = "#{@blog.title} Posts"
    def subtitle = "Select posts"

    def template(&)
      render ApplicationForm.new(@batch, action: url_for) do |form|
        render TableComponent.new(items: @batch) do |table|
          table.column do |column|
            column.item do |selection|
              # input(type: "checkbox", value: selection.selected, name: "batch[items][#{selection.id}][selected]")
              # render ItemForm.new selection
              form.collection(:items) do |selection|
                render selection.field(:selected).input(type: :checkbox, value: "on")
              end
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
              button(form.field(:action), value: "delete") { "Delete" }
            end
            li do
              button(form.field(:action), value: "publish") { "Publish" }
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
