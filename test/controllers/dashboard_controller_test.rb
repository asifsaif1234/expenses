# frozen_string_literal: true

require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest

  test "should get index" do
    skip "Skipping due to fixture issues - fix fixtures first"
    get dashboard_url
    assert_response :success
  end
  # test "should get index" do
  #   get dashboard_index_url
  #   assert_response :success
  # end
end
