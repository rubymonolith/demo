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
    @turbo_meta_tags = self.class.turbo_meta_tags
    super(...)
  end

  def render(view, ...)
    @forms.push view if view.is_a? ApplicationForm
    super(view, ...)
  end

  def around_template(&)
    render PageLayout.new(title: proc { title }, subtitle: proc { subtitle }, turbo: @turbo_meta_tags) do
      super(&)
    end
  end
end
