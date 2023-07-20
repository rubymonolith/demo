class PageLayout < ApplicationLayout
  def initialize(title: nil, subtitle: nil)
    @title = title
    @subtitle = subtitle
  end

  def template(&)
    super do
      header(class: "container") do
        if @title and @subtitle
          hgroup do
            h1(&@title)
            h2(&@subtitle)
          end
        else
          h1 { @title }
        end
      end
      main(class: "container", &)
      footer(class: "container") do
        small do
          plain "This demo application is erased on every deploy. Read more about it at "
          link_to("https://fly.io/ruby-dispatch/component-driven-development-on-rails-with-phlex") do
            "Component Driven Development"
          end
          plain " or view the "
          link_to("https://github.com/rubymonolith/demo") { "source code on Github" }
          plain "."
        end
      end
    end
  end
end