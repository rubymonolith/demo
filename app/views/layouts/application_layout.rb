# frozen_string_literal: true

class ApplicationLayout < ApplicationComponent
  include Phlex::Rails::Layout

  def initialize(title:)
    @title = title
  end

  def template(&)
    doctype

    html do
      head do
        # title(&@title)
        title { render @title }
        meta name: "viewport", content: "width=device-width,initial-scale=1"
        csp_meta_tag
        csrf_meta_tags
        stylesheet_link_tag "application", data_turbo_track: "reload"
        javascript_importmap_tags
      end

      body(&)
    end
  end
end
