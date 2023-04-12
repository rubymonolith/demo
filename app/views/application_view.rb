# frozen_string_literal: true

class ApplicationView < ApplicationComponent
	include LinkHelpers

	attr_writer :resource, :resources
	attr_reader :forms

	def title = nil
	def subtitle = nil

	def initialize(...)
		@forms = []
		super(...)
	end

	def render(view, ...)
		@forms.push view if view.is_a? ApplicationForm
		super(view, ...)
	end

	def around_template(&)
		render PageLayout.new(title: proc { title }, subtitle: proc { subtitle }) do
			super(&)
		end
	end
end
