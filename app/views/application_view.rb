# frozen_string_literal: true

class ApplicationView < ApplicationComponent
  include LinkHelpers

  attr_writer :resource, :resources
  attr_reader :forms

  def title = nil
  def subtitle = nil

  def list(collection, &item_template)
    render ListComponent.new(items: collection) do |list|
      list.item(&item_template)
    end
  end

  def initialize(...)
    @forms = []
    super(...)
  end

  def render(view, ...)
    @forms.push view if view.is_a? ApplicationForm
    super(view, ...)
  end

  def around_template(&)
    render PageLayout.new(title: method(:title), subtitle: -> { subtitle }) do
      super(&)
    end
  end
end
