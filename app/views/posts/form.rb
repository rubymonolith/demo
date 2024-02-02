module Posts
  class Form < ApplicationForm
    def template
      labeled field(:blog_id).select Blog.select(:id, :title), nil
      # Same thing as above, but multiple lines. Useful for optgroups.
      # labeled field(:blog).select do
      #   _1.options(Blog.select(:id, :title))
      #   _1.blank_option
      # end

      labeled field(:title).input.focus
      labeled field(:publish_at).input
      labeled field(:content).textarea(rows: 6)

      submit
    end
  end
end