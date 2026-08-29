# frozen_string_literal: true

module ApplicationHelper
  def active_nav_class(path)
    current_page?(path) ? "text-gray-900 font-semibold" : "text-gray-600 hover:text-gray-900"
  end
end
