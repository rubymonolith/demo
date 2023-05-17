class Blogs::Batch::PostsController < ApplicationController
  assign :posts, through: :blogs, from: :current_user

  # TODO: How can I compose `assign :posts, ... with `resources`?
  include Batchable
  def scope
    @blog.posts
  end
  # / TODO: How can I compose `assign :posts, ... with `resources`?

  class Index < ApplicationView
    attr_accessor :posts, :blog, :current_user, :selection

    def title = "#{@blog.title} Posts"
    def subtitle
      plain "Select posts from "
      show(@blog, :title)
    end

    def template(&)
      render ApplicationForm.new(@selection, action: url_for) do |form|
        render TableComponent.new(items: @selection.items) do |table|
          table.column do |column|
            column.item do |item|
              form.collection(:selected) do |selection|
                render selection.field(value: item.id).input(type: :checkbox)
              end
            end
          end
          table.column("Title")         { show(_1, :title) }
          table.column("Author")        { show(_1.user, :name) }
          table.column("Status")        { _1.status }
          table.column("Publish Date")  { _1.publish_at&.to_formatted_s(:long) }
        end

        nav do
          ul do
            li do
              render form.field(:action, value: "delete").button
            end
            li do
              render form.field(:action, value: "publish").button
            end
            li do
              render form.field(:action, value: "unpublish").button
            end
            li do
              show(@blog) { "Cancel selection" }
            end
          end
        end
      end
    end
  end

  def delete
    @selection.selected_items.delete_all
    redirect_to action: :index
  end

  def publish
    @selection.selected_items.update_all(publish_at: Time.current)
    redirect_to action: :index
  end

  def unpublish
    @selection.selected_items.update_all(publish_at: nil)
    redirect_to action: :index
  end
end
