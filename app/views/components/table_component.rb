class TableComponent < ApplicationComponent
  include Phlex::DeferredRender

  class Column
    attr_accessor :title_template, :item_template

    def title(&block)
      @title_template = block
    end

    def item(&block)
      @item_template = block
    end

    def self.build(title:, &block)
      new.tap do |column|
        column.title { title }
        column.item(&block)
      end
    end
  end

  def initialize(items: [])
    @items = items
    @columns = []
  end

  def template(&)
    table do
      thead do
        tr do
          @columns.each do |column|
            th(&column.title_template)
          end
        end
      end
      tbody do
        @items.each do |item|
          tr do
            @columns.each do |column|
              td { column.item_template.call(item) }
            end
          end
        end
      end
    end
  end

  def column(title = nil, &block)
    @columns << if title
      Column.build(title: title, &block)
    else
      Column.new.tap(&block)
    end
  end
end
