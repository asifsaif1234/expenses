# frozen_string_literal: true

class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index ]

  # Use a different layout for landing page
  layout "landing"

  def index
    # This is the main landing page
    # You can add any instance variables here if needed
  end
end
