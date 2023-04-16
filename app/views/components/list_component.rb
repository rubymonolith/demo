class ListComponent < ApplicationComponent
  include Phlex::DeferredRender

  def initialize(items:)
    @items = items
  end

  def template(&)
    @items.each do |item|
      li { @item_template.call(item) }
    end
  end

  def item(&item_template)
    @item_template = item_template
  end

  def around_template(&)
    ol { super }
  end
end
