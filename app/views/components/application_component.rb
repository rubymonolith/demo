# frozen_string_literal: true

class ApplicationComponent < Phlex::HTML
  include Phlex::Rails::Helpers::Routes
  include LinkHelpers
  include Superview::Turbo::Helpers

  if Rails.env.development?
    def before_template
      comment { "Before #{self.class.name}" }
      turbo if respond_to? :turbo
      super
    end
  end
end
