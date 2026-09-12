# frozen_string_literal: true

require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  # Test public landing page (no auth required)
  test "should get index" do
    get home_index_url
    assert_response :success
  end
end
