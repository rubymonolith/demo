# frozen_string_literal: true

class ApplicationView < ApplicationComponent
	attr_writer :resource, :resources

	attr_reader :forms

	def initialize(...)
		@forms = []
		super(...)
	end

	def render(view, ...)
		@forms.push view if view.is_a? ApplicationForm
		super(view, ...)
	end
end
