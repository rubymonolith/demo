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
                # selection.namespace :spartan do |spartan|
                #   render spartan.field(:bulldog, value: true).input
                # end
                # selection.collection :even_more do |funston|
                #   10.times do |n|
                #     render funston.field(value: n).input
                #   end
                # end
                render selection.field(value: item.id).input(type: :checkbox, checked: @selection.selected?(item.id))
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
              render form.field(:action).button(value: "delete")
            end
            li do
              render form.field(:action).button(value: "publish")
            end
            li do
              render form.field(:action).button(value: "unpublish")
            end
            li do
              if @selection.selected?
                render form.field(:action).button(value: "select_none")
              else
                render form.field(:action).button(value: "select_all")
              end
            end
            li do
              show(@blog) { "Back to Blog" }
            end
          end
        end
      end
    end
  end

  def delete
    @selection.selected_items.delete_all
    render phlex_action(:index), status: :created
  end

  def publish
    @selection.selected_items.update_all(publish_at: Time.current)
    render phlex_action(:index), status: :created
  end

  def unpublish
    @selection.selected_items.update_all(publish_at: nil)
    render phlex_action(:index), status: :created
  end

  def select_none
    @selection.select_none
    render phlex_action(:index), status: :created
  end

  def select_all
    @selection.select_all
    render phlex_action(:index), status: :created
  end
end
